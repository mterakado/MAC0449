USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///authorsInfo.csv" AS row CREATE (autor:Autor {nomeAutor: row.author_name, autorID: toInt(row.author_id)});

CREATE INDEX ON :Autor(autorID);
CREATE INDEX ON :Autor(nomeAutor);

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///journalsTitle.csv" AS row CREATE (:Revista {nomeRevista: row.journal_title, revistaID: toInt(row.journal_id)});

CREATE INDEX ON :Revista(revistaID);
CREATE INDEX ON :Revista(nomeRevista);

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///journalsKeywords.csv" AS row
MATCH (revista:Revista {revistaID: toInt(row.journal_id)})
SET revista.palavraChave = row.journal_keywords
RETURN revista;

USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///journalsDescription.csv" AS row
MATCH (revista:Revista {revistaID: toInt(row.journal_id)})
SET revista.descricao = row.journal_description
RETURN revista;

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///articlesTitle.csv" AS row CREATE (:Artigo {tituloArtigo: row.article_title, artigoID: toInt(row.article_id), dataPublicacao: row.date_submitted});

CREATE INDEX ON :Artigo(artigoID);
CREATE INDEX ON :Artigo(tituloArtigo);

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///articlesDoi.csv" AS row MATCH (artigo:Artigo {artigoID: toInt(row.article_id)}) SET artigo.doi = row.article_doi RETURN artigo;

CREATE INDEX ON :Artigo(doi);

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///articlesKeywords.csv" AS row MATCH (artigo:Artigo {artigoID: toInt(row.article_id)}) SET artigo.palavrasChave = row.article_keywords RETURN artigo;

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///articlesAbstract.csv" AS row MATCH (artigo:Artigo {artigoID: toInt(row.article_id)}) SET artigo.resumo = row.article_abstract;

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///countries.csv" AS row CREATE (:Local {nomePais: row.country_name, siglaPais: row.country_code});

CREATE INDEX ON :Local(nomePais);
CREATE INDEX ON :Local(siglaPais);

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///authorsInfo.csv" AS row CREATE (:Afiliacao {nomeUniversidade: row.university, nomeInstituto: row.institute});

CREATE INDEX ON :Afiliacao(nomeUniversidade);
CREATE INDEX ON :Afiliacao(nomeInstituto);

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///articlesTitle.csv" AS row MATCH (artigo:Artigo {artigoID: toInt(row.article_id)}) MATCH (revista:Revista {revistaID: toInt(row.journal_id)}) MERGE (artigo)-[r:FOI_PUBLICADO_EM]->(revista) RETURN r;

LOAD CSV WITH HEADERS FROM "file:///authorsInfo.csv" AS row MATCH (autor:Autor {autorID: toInt(row.author_id)}) MATCH (artigo:Artigo {artigoID: toInt(row.submission_id)}) MERGE (artigo)-[:FOI_PUBLICADO_POR]->(autor);

LOAD CSV WITH HEADERS FROM "file:///authorsInfo.csv" AS row MATCH (autor:Autor {autorID: toInt(row.author_id)})
MATCH (local:Local:Pais {sigla: row.country}) MERGE (autor)-[:E_DE]->(local);

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///authorsInfo.csv" AS row MATCH (autor:Autor {autorID: toInt(row.author_id)}) MATCH (afiliacao:Afiliacao {nomeUniversidade: row.university}) MERGE (autor)-[:E_FILIADO_A]->(afiliacao);

USING PERIODIC COMMIT LOAD CSV WITH HEADERS FROM "file:///journalsInstituion.csv" AS row MATCH (revista:Revista {revistaID: toInt(row.journal_id)}) MATCH (afiliacao:Afiliacao {nomeUniversidade: row.journal_university}) MERGE (revista)-[:PERTENCE_A]->(afiliacao);

LOAD CSV WITH HEADERS FROM "file:///visualizInfo.csv" AS row MATCH (artigo:Artigo {artigoID: toInt(row.assoc_id)}) MATCH (local:Local {siglaPais: row.country_id, nomeCidade:row.city}) MERGE (artigo)-[:TEM_VISUALIZACAO_VINDO_DE {dataVisualizacao: row.day, mesVisualizacao: row.month, anoVisualizacao: row.year}]->(local);

LOAD CSV WITH HEADERS FROM "file:///downloadInfo.csv" AS row MATCH (artigo:Artigo {artigoID: toInt(row.assoc_id)}) MATCH (local:Local {siglaPais: row.country_id, nomeCidade:row.city}) MERGE (artigo)-[:TEM_DOWNLOAD_VINDO_DE {dataDownload: row.day, mesDownload: row.month, anoDownload: row.year}]->(local);
