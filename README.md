This scraper aggregates and normalises datasets for [gotgastroagain.com](https://gotgastroagain.com).

**Learn how to [add a new dataset](https://github.com/auxesis/gastro/blob/master/docs/contributing-datasets.markdown).**

It currently pulls in data from:

 - New South Wales: [auxesis/nsw_food_authority_penalty_notices](https://morph.io/auxesis/nsw_food_authority_penalty_notices)
 - New South Wales: [auxesis/nsw_food_authority_prosecution_notices](https://morph.io/auxesis/nsw_food_authority_prosecution_notices)
 - Victoria: [auxesis/vic_health_register_of_convictions](https://morph.io/auxesis/vic_health_register_of_convictions)
 - Western Australia: [auxesis/wa_health_food_offenders](https://morph.io/auxesis/wa_health_food_offenders)
 - South Australia: [auxesis/sa_health_food_prosecutions_register](https://morph.io/auxesis/sa_health_food_prosecutions_register)
 - UK: [auxesis/uk_fsa_food_law_prosecutions](https://morph.io/auxesis/uk_fsa_food_law_prosecutions)

When the scraper finishes, it calls [gotgastroagain.com/reset](https://gotgastroagain.com/reset) (with a token) to signal new data is available.

This scraper [runs on Morph](https://morph.io/auxesis/wa_health_food_offenders). To get started [see Morph's documentation](https://morph.io/documentation).
