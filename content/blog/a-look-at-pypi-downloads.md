# A Look at PyPI Download Statistics

- date: 2013-10-12

-------------------------------------------------------------------------------

A quick introspection into the traffic that hits the [PyPI][1] CDN, a snapshot
of roughly 4 days of traffic. In that time PyPI served 66.7 million requests
for a total of 4.1 terabytes of data. The [Fastly][2] provided CDN has averaged
an 85% hit rate on the cache.

[1]: https://pypi.python.org/
[2]: http://fastly.com/


## Request Types

![Types of Requests](/images/a-look-at-pypi-downloads/traffic_type.png)


## Python Versions

![Python Versions](/images/a-look-at-pypi-downloads/python_versions.png)


## Installers

![Installers](/images/a-look-at-pypi-downloads/installers.png)
