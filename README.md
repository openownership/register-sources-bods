# Register Sources BODS

Register Sources BODS is designed for inclusion as a library for use with any BODS data source. See https://standard.openownership.org/en/0.2.0/ for an example of their data standard.

There are three primary purposes for this library:

- Providing typed objects for the JSON-line data. It makes use of the dry-types and dry-struct gems to specify the different object types allowed in the data returned.
- For use with an Elasticsearch database for
persisting the BODS records. This functionality includes creating a mapping for indexing the possible fields observed as well as functions for storage and retrieval.
- For publishing BODS statements to a designated Kinesis stream.

This library does not include transformation to BODS format of other data standards. That is instead left as the purpose of the transformer gems, such as register-transformer-psc.

This has been tested with v7.17 of Elasticsearch.

## Configuration

Make an .env filed based on the keys listed in .env.example as follows:
```
ELASTICSEARCH_HOST=
ELASTICSEARCH_PORT=
ELASTICSEARCH_PROTOCOL=
ELASTICSEARCH_SSL_VERIFY=
ELASTICSEARCH_PASSWORD=

BODS_S3_BUCKET_NAME=
BODS_AWS_REGION=
BODS_AWS_ACCESS_KEY_ID=
BODS_AWS_SECRET_ACCESS_KEY=

BODS_STREAM=
```

- BODS_STREAM is an optional - if provided then any newly generated BODS statements will be published to the Kinesis stream with this name before being stored in Elasticsearch
- Configure Elasticsearch Credentials as normal
- Configure AWS credentials as normal

## Tests

To execute the tests, first build the container (bin/build) and then run:

```shell
bin/test
```
