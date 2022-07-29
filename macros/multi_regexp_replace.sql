{#
  Example usage:

  /* `replacement_pairs` is used for the multi_regexp_replace macro referenced below. The macro uses the
      listed pairs in `replacement_pairs` to compile multiple regexp_replace statements. The order in
      which the pairs are listed impacts the order in which they are applied (i.e., the first one listed
      will be applied first). */

  {% set replacement_pairs = {
      '\\\\d+\\\\b':''
      , '\\\\.':' > '
      , '_':' '
      , 'Eod\\\\b':'EOD'
      }
  %}

  select
      {{ multi_regexp_replace('initcap(example_field)', replacement_pairs) }} as example
  ...
#}

{# subject: Any valid column or calculation
   replacement_pairs: dictionary with pattern: replacement  #}
{%- macro multi_regexp_replace(subject, replacement_pairs) -%}

  {# Using namespace because of [jinja scoping behavior](https://jinja.palletsprojects.com/en/2.11.x/templates/#assignments) #}
  {%- set ns = namespace(output='') -%}

  {# Iterate through replacement_pairs dictionary #}
  {%- for pattern, replacement in replacement_pairs.items() -%}

    {# If it is the first iteration through the for loop then use subject instead of output #}
    {%- if loop.first -%}

      {# Set output string equal to first replace
         Example: regexp_replace('.example!', '!', '') #}
      {%- set ns.output = "regexp_replace(" ~ subject ~ ", '" ~ pattern ~ "', '" ~ replacement ~ "')" -%}

    {%- else -%}

      {# Set output string equal to previous replace(s) and add next replace
         Example: regexp_replace(regexp_replace('.example!', '!', ''), '\\\\.', ' > ') #}
      {%- set ns.output = "regexp_replace(" ~ ns.output ~ ", '" ~ pattern ~ "', '" ~ replacement ~ "')" -%}

    {%- endif -%}

  {%- endfor -%}

  {# print final output #}
  {{ ns.output }}

{%- endmacro -%}
