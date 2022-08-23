/* This macro converts the product's 5-star rating into the client's proprietary rating */

{% macro superclient_rating(review_rating) -%}
    case 
        when 0.97*5 < {{ review_rating }} <= 1.00*5 THEN 'A+'
        when 0.93*5 < {{ review_rating }} <= 0.97*5 THEN 'A'
        when 0.90*5 < {{ review_rating }} <= 0.93*5 THEN 'A-'
        when 0.87*5 < {{ review_rating }} <= 0.90*5 THEN 'B+'
        when 0.83*5 < {{ review_rating }} <= 0.87*5 THEN 'B'
        when 0.80*5 < {{ review_rating }} <= 0.83*5 THEN 'B-'
        when 0.77*5 < {{ review_rating }} <= 0.80*5 THEN 'C+'
        when 0.73*5 < {{ review_rating }} <= 0.77*5 THEN 'C'
        when 0.70*5 < {{ review_rating }} <= 0.73*5 THEN 'C-'
        when 0.67*5 < {{ review_rating }} <= 0.70*5 THEN 'D+'
        when 0.65*5 < {{ review_rating }} <= 0.67*5 THEN 'D'
        else 'F+'
    end
{%- endmacro %}