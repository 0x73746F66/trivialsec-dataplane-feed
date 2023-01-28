import models

feeds: list[models.FeedConfig] = [
    models.FeedConfig(
        name="sshclient",
        url="https://dataplane.org/sshclient.txt",
        source="dataplane.org",
        disabled=False
    ),
    models.FeedConfig(
        name="sshpwauth",
        url="https://dataplane.org/sshpwauth.txt",
        source="dataplane.org",
        disabled=False
    ),
    models.FeedConfig(
        name="dnsrd",
        url="https://dataplane.org/dnsrd.txt",
        source="dataplane.org",
        disabled=False
    ),
    models.FeedConfig(
        name="vncrfb",
        url="https://dataplane.org/vncrfb.txt",
        source="dataplane.org",
        disabled=False
    ),
]
