library(RNeo4j)
library(igraph)

neo4j = startGraph("http://localhost:7474/db/data/", username = "neo4j")
	
nodes_query = "
MATCH (:Artigo)-[:FOI_PUBLICADO_POR]->(a:Autor)
RETURN DISTINCT ID(a) AS id, a.nomeAutor AS nome
"

edges_query = "
MATCH (a1:Autor)<-[:FOI_PUBLICADO_POR]-(:Artigo)-[:FOI_PUBLICADO_POR]->(a2:Autor)
RETURN ID(a1) AS source, ID(a2) AS target
"

nodes = cypher(neo4j, nodes_query)
edges = cypher(neo4j, edges_query)

autGraph = graph.data.frame(edges, directed = FALSE, nodes)

# Run Girvan-Newman clustering algorithm
communities = edge.betweenness.community(autGraph)

# Extract cluster assignments and merge with nodes data.frame.
memb = data.frame(name = communities$names, cluster = communities$membership)
nodes = merge(nodes, memb)

nodes = nodes[c("id", "name", "cluster")]
