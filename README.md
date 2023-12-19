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
docker compose run sources-bods ingest-local statements/xx.jsonl raw-xx
docker compose run sources-bods ingest-local statements/xx.jsonl raw-xx xx-dev
```

To local transform `xx.jsonl` file from `raw-xx` index into `bods_v2_xx_dev1` index, optionally publishing to `bods-xx-dev` Kinesis stream:

```sh
docker compose run sources-bods transform-local statements/xx.jsonl raw-xx bods_v2_xx_dev1
docker compose run sources-bods transform-local statements/xx.jsonl raw-xx bods_v2_xx_dev1 bods-xx-dev
```

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
