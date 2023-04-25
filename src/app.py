import json
from uuid import uuid5
from datetime import datetime, timezone

from lumigo_tracer import lumigo_tracer

import internals
import config
import models
import services.aws


def process(feed: models.FeedConfig) -> list[models.DataPlane]:
    internals.logger.debug("fetch")
    results = []
    if feed.disabled:
        internals.logger.info(f"{feed.name} [magenta]disabled[/magenta]")
        return []
    file_path = internals.download_file(feed.url)
    if not file_path.exists():
        internals.logger.warning(f"Failed to retrieve {feed.name}")
        return []
    contents = file_path.read_text(encoding='utf8')
    if not contents:
        return []
    for line in contents.splitlines():
        if line.startswith('#'):
            continue
        asn, asn_text, ip_address, last_seen, category, *_ = line.split("  |  ")
        asn = asn.strip()
        asn_text = asn_text.strip()
        ip_address = ip_address.strip()
        last_seen = last_seen.strip()
        category = category.strip()
        if not ip_address:
            continue
        now = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
        data = models.DataPlane(
            address_id=uuid5(internals.DATAPLANE_NAMESPACE, ip_address),
            ip_address=ip_address,
            feed_name=category,
            feed_url=feed.url,
            first_seen=now,
            last_seen=datetime.fromisoformat(last_seen),
            asn=None if asn == "NA" else asn,
            asn_text=None if asn_text == "NA" else asn_text,
        )
        if not data.exists() and data.save() and services.aws.store_sqs(
            queue_name=f'{internals.APP_ENV.lower()}-early-warning-service',
            message_body=json.dumps({**data.dict(), **{'source': feed.source}}, cls=internals.JSONEncoder),
            deduplicate=False,
        ):
            results.append(data)

    return results


def main():
    for feed in config.feeds:
        internals.logger.info(f"{len(process(feed))} queued records -> {feed.name}")


def handler(event, context):
    # hack to dynamically retrieve the token fresh with each Lambda invoke
    @lumigo_tracer(
        token=services.aws.get_ssm(f'/{internals.APP_ENV}/{internals.APP_NAME}/Lumigo/token', WithDecryption=True),
        should_report=internals.APP_ENV == "Prod",
        skip_collecting_http_body=True
    )
    def main_wrapper():
        main()
    main_wrapper()
