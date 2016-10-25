This scraper aggregates and normalises datasets for [gotgastroagain.com](https://gotgastroagain.com).

It currently pulls in data from:

 - New South Wales: [auxesis/nsw_food_authority_penalty_notices](https://morph.io/auxesis/nsw_food_authority_penalty_notices)
 - New South Wales: [auxesis/nsw_food_authority_prosecution_notices](https://morph.io/auxesis/nsw_food_authority_prosecution_notices)
 - Victoria: [auxesis/vic_health_register_of_convictions](https://morph.io/auxesis/vic_health_register_of_convictions)
 - Western Australia: [auxesis/wa_health_food_offenders](https://morph.io/auxesis/wa_health_food_offenders)

When the scraper finishes, it calls [gotgastroagain.com/reset](https://gotgastroagain.com/reset) (with a token) to signal new data is available.

This scraper [runs on Morph](https://morph.io/auxesis/wa_health_food_offenders). To get started [see Morph's documentation](https://morph.io/documentation).
