# Register Sources BODS

Register Sources BODS is a shared library for the [OpenOwnership](https://www.openownership.org/en/) [Register](https://github.com/openownership/register) project.
It is designed for use with any [Beneficial Ownership Data Standard (BODS)](https://www.openownership.org/en/topics/beneficial-ownership-data-standard/) format data source.

The primary purposes of this library are:

- Providing typed objects for the JSON-line data. It makes use of the dry-types and dry-struct gems to specify the different object types allowed in the data returned.
- Persisting the BODS records using Elasticsearch. This functionality includes creating a mapping for indexing the possible fields observed as well as functions for storage and retrieval.
- Publishing BODS statements to a designated Kinesis stream.

This library does not include transformation to BODS format of other data standards. That is instead left as the purpose of the Register Transformers.

The data standard is [BODS 0.2](https://standard.openownership.org/en/0.2.0/schema/schema-browser.html).

## Installation

Install and boot [Register](https://github.com/openownership/register).

Configure your environment using the example file:

```sh
cp .env.example .env
```

## Testing

Run the tests:

```sh
docker compose run sources-bods test
```

## Usage

### Static BODS Local

To local ingest `xx.jsonl` file into `raw-xx` index, optionally publishing to `xx-dev` Kinesis stream:

```sh
docker compose run sources-bods ingest-local data/imports/xx.jsonl raw-xx
docker compose run sources-bods ingest-local data/imports/xx.jsonl raw-xx xx-dev
```

To local transform `xx.jsonl` file from `raw-xx` index into `bods_v2_xx_dev1` index, optionally publishing to `bods-xx-dev` Kinesis stream:

```sh
docker compose run sources-bods transform-local data/imports/xx.jsonl raw-xx bods_v2_xx_dev1
docker compose run sources-bods transform-local data/imports/xx.jsonl raw-xx bods_v2_xx_dev1 bods-xx-dev
```

Optionally, `0` can be appended to the command to disable resolving via Open Corporates. In case disabling is required but publishing to a Kinesis stream isn't, `'' 0` can be used as the final two arguments.

### Static BODS Bulk

To bulk ingest `raw/xx/` S3 prefix into `raw-xx` index, optionally publishing to `xx-dev` Kinesis stream:

```sh
docker compose run sources-bods ingest-bulk raw/xx/ raw-xx
docker compose run sources-bods ingest-bulk raw/xx/ raw-xx xx-dev
```

To bulk transform `raw/xx/` S3 prefix from `raw-xx` index into `bods_v2_xx_dev1` index, optionally publishing to `bods-xx-dev` Kinesis stream:

```sh
docker compose run sources-bods transform-bulk raw/xx/ raw-xx bods_v2_xx_dev1
docker compose run sources-bods transform-bulk raw/xx/ raw-xx bods_v2_xx_dev1 bods-xx-dev
```

Optionally, `0` can be appended to the command to disable resolving via Open Corporates. In case disabling is required but publishing to a Kinesis stream isn't, `'' 0` can be used as the final two arguments.

### Bulk Data Export

1.  Ingest OC bulk data
2.  Ingest PSC bulk data
3.  Ingest DK bulk data
4.  Ingest SK bulk data
5.  Transform PSC bulk data
6.  Transform DK bulk data
7.  Transform SK bulk data
8.  Download S3 files (after 5m)
    `aws s3 sync --delete s3://oo-register-v2/ ~/clones/oo-register-v2/`
9.  Combine PSC files
    `combine data/imports/source=PSC/ data/exports/prd/ psc`
10. Combine DK files
    `combine data/imports/source=DK/ data/exports/prd/ dk`
11. Combine SK files
    `combine data/imports/source=SK/ data/exports/prd/ sk`
12. Combine All files
    `combine-all data/exports/prd/`
13. Upload S3 files
    `aws s3 sync ~/code/register-sources-bods/data/exports/prd/     s3://oo-register-v2/exports/`
    `aws s3 sync ~/code/register-sources-bods/data/exports/prd/all/ s3://public-bods/exports/`

- (1-4) can be done in any order or in parallel
- (5) depends on (1, 2), (6) depends on (1, 3), (7) depends on (1, 4), but otherwise can be done in any order or in parallel
- (8) depends on (5-7)
- (9-11) depend on (8)
- (12) depends on (9-11)
- (13) depends on (9-12)
