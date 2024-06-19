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

## Monthly bulk data tasks

In order to perform the monthly bulk data tasks, it is necessary to import the latest raw data, process the raw data to turn it into BODS statements, and export the BODS statements to compressed files available for download internally and from the Register website. These tasks span multiple repositories and commands.

All of these commands should be run on the Register server in EC2 (`bods-register`).

### Ingester (Import)

Ingester OC, Ingester PSC, Ingester DK, and Ingester SK steps can be done in any order, or in parallel.

#### Ingester OC

<https://github.com/openownership/register-ingester-oc?tab=readme-ov-file#helper-script>

Checkout the latest code and build via Docker:

```sh
cd ~/register-ingester-oc/
git checkout main
git pull
docker compose build
```

Ingest the bulk data, where `YYYY-MM-DD` is the date the Open Corporates FTP files were published:

```sh
docker compose run ingester-oc ingest-bulk YYYY-MM-DD
```

This will ask you for the FTP password, 3 times.

#### Ingester PSC

<https://github.com/openownership/register-ingester-psc?tab=readme-ov-file#snapshots-using-the-helper-script>

Note that there is also a streaming ingester service running on Heroku (`register-ingester-psc-prd`). It might not be necessary to complete the rest of this step if that process is all working correctly without missed data (not currently the case).

Checkout the latest code and build via Docker:

```sh
cd ~/register-ingester-psc/
git checkout main
git pull
docker compose build
```

Ingest the bulk data:

```sh
docker compose run ingester-psc ingest-bulk
```

#### Ingester DK

<https://github.com/openownership/register-ingester-dk?tab=readme-ov-file#usage>

Checkout the latest code and build via Docker:

```sh
cd ~/register-ingester-dk/
git checkout master
git pull
docker compose build
```

Ingest the bulk data:

```sh
docker compose run ingester-dk ingest-bulk
```

#### Ingester SK

<https://github.com/openownership/register-ingester-sk?tab=readme-ov-file#usage>

Checkout the latest code and build via Docker:

```sh
cd ~/register-ingester-sk/
git checkout main
git pull
docker compose build
```

Ingest the bulk data:

```sh
docker compose run ingester-sk ingest-bulk
```

### Transformer (Process)

Transformer PSC, Transformer DK, and Transformer SK steps can be done in any order, or in parallel, once their dependencies are satisfied.

#### Transformer PSC

Transformer PSC step depends on Ingester OC and Ingester PSC steps.

<https://github.com/openownership/register-transformer-psc?tab=readme-ov-file#bulk-data>

Note that there is also a streaming transformer service running on Heroku (`register-transformer-psc-prd`). It might not be necessary to complete the rest of this step if that process is all working correctly and no additional bulk data had to be imported.

Checkout the latest code and build via Docker:

```sh
cd ~/register-transformer-psc/
git checkout main
git pull
docker compose build
```

Transform the bulk data, where `YYYY` and `MM` are the current year and month to be transformed:

```sh
docker compose run transformer-psc transform-bulk raw_data/source=PSC/year=YYYY/month=MM/
```

#### Transformer DK

Transformer DK step depends on Ingester OC and Ingester DK steps.

<https://github.com/openownership/register-transformer-dk?tab=readme-ov-file#usage>

Checkout the latest code and build via Docker:

```sh
cd ~/register-transformer-dk/
git checkout master
git pull
docker compose build
```

Transform the bulk data, where `YYYY` and `MM` are the current year and month to be transformed:

```sh
docker compose run transformer-dk transform-bulk raw_data/source=DK/year=YYYY/month=MM/
```

#### Transformer SK

Transformer SK step depends on Ingester OC and Ingester SK steps.

<https://github.com/openownership/register-transformer-sk?tab=readme-ov-file#usage>

Checkout the latest code and build via Docker:

```sh
cd ~/register-transformer-sk/
git checkout main
git pull
docker compose build
```

Transform the bulk data, where `YYYY` and `MM` are the current year and month to be transformed:

```sh
docker compose run transformer-sk transform-bulk raw_data/source=SK/year=YYYY/month=MM/
```

### Combiner (Export)

Download S3 files and all subsequent Combiner steps depend on Transformer steps being completed.

<https://github.com/openownership/register-sources-bods>

<https://github.com/openownership/register/issues/265#issuecomment-2165306401>

#### Update

Checkout the latest code and build via Docker:

```sh
cd ~/register-sources-bods/
git checkout main
git pull
docker compose build
```

#### Download S3 files

Download the files:

```sh
sync-clones
```

#### Combine PSC

Combine the files:

```sh
docker compose run sources-bods combine data/imports/source=PSC/ data/exports/prd/ psc
```

#### Combine DK

Combine the files:

```sh
docker compose run sources-bods combine data/imports/source=DK/ data/exports/prd/ dk
```

#### Combine SK

Combine the files:

```sh
docker compose run sources-bods combine data/imports/source=SK/ data/exports/prd/ sk
```

#### Combine All

Combine the files:

```sh
docker compose run sources-bods combine-all data/exports/prd/
```

#### Upload S3 files

Upload the files:

```sh
sync-exports-tx
```

#### Check Register website

Check that the All compressed file appears on the Register website automatically:

<https://register.openownership.org/download>

#### Announce

Announce the availability of bulk data exports internally on Slack in `#oo-technology` channel.
