\copy (SELECT distinct(art.article_id), journal_id, date_submitted, setting_value AS article_title FROM articles art JOIN article_settings arts ON arts.article_id = art.article_id WHERE setting_name = 'cleanTitle') TO './articlesTitle.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT distinct(art.article_id), journal_id, date_submitted, setting_value AS article_keywords FROM articles art JOIN article_settings arts ON arts.article_id = art.article_id WHERE setting_name = 'subject' AND arts.locale = 'pt_BR') TO './articlesKeywords.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT distinct(art.article_id), setting_value AS article_abstract FROM articles art JOIN article_settings arts ON arts.article_id = art.article_id WHERE setting_name = 'abstract') TO './articlesAbstract.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT distinct(art.article_id), setting_value AS article_doi FROM articles art JOIN article_settings arts ON arts.article_id = art.article_id WHERE setting_name = 'pub-id::doi') TO './articlesDoi.csv' DELIMITER ',' CSV HEADER; 

\copy (SELECT distinct(aut.author_id), submission_id, first_name::text || ' ' || middle_name::text || ' ' || last_name::text AS author_name, country, setting_value AS affiliation FROM authors aut JOIN author_settings auts ON auts.author_id = aut.author_id WHERE setting_name = 'affiliation') TO './authorsInfo.csv' DELIMITER ',' CSV HEADER; 

\copy (SELECT assoc_id, day, country_id, city, assoc_type, metric_type FROM metrics WHERE assoc_id IN (SELECT assoc_id FROM metrics WHERE assoc_id IN (SELECT DISTINCT article_id FROM articles) GROUP BY assoc_id ORDER BY count(*) DESC LIMIT 250)) TO './metricsInfo.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT distinct(j.journal_id), setting_value AS journal_title FROM journals j JOIN journal_settings js ON js.journal_id = j.journal_id WHERE setting_name = 'title' ORDER BY j.journal_id) TO './journalsTitle.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT DISTINCT(j.journal_id), setting_value AS journal_keywords FROM journals j JOIN journal_settings js ON js.journal_id = j.journal_id WHERE setting_name = 'searchKeywords' AND locale='pt_BR' ORDER BY j.journal_id) TO './journalsKeywords.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT distinct(j.journal_id), setting_value AS journal_description FROM journals j JOIN journal_settings js ON js.journal_id = j.journal_id WHERE setting_name = 'searchDescription' ORDER BY j.journal_id) TO './journalsDescription.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT distinct(j.journal_id), setting_value AS journal_institution FROM journals j JOIN journal_settings js ON js.journal_id = j.journal_id WHERE setting_name = 'publisherInstitution' ORDER BY j.journal_id) TO './journalsInstituion.csv' DELIMITER ',' CSV HEADER;

 
