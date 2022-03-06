# docker-find

Let's automate some docker forensics! Search for specific terms in a docker image.

## Inspired by docker-based challenges on CTFs

Examples

- [Whale Watching](https://ctftime.org/task/12575)

```
$ ./docker-find.sh johnhammond/whale_watching flag{
```

- [Peel back the layers](https://ctftime.org/task/18090)

```
$ ./docker-find.sh steammaintainer/gearrepairimage HTB{
```

## Usage

```
$ ./docker-find [image] [search-term]
```

## Search Steps

1. search `docker history`
1. search `docker inspect`
1. search layers
    1. run `grep` on layer files
    1. run `strings` on layer files


## References

- [docker-forensics](https://book.hacktricks.xyz/forensics/basic-forensic-methodology/docker-forensics)
