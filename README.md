This dbt macro will output to command line some LookML that represents the current state of a model in your environment.

This might be useful if you'd like to test your dbt changes inside Looker, prior to merging the dbt code into production.

To use it, place the following into your command line:
```
dbt run-operation generate_lookml --args '{model_name: 'dim_order'}'
```

Currently, this has only been tested on Snowflake and doesn't handle things such as dimension_groups.

I'm aware of dbt2looker Python library but didn't like that you could not specify a single model.

Ideally in the future I would like to bulk out the functionality of this macro and release it as a dbt package.