library(RNeo4j)
library(igraph)
library(visNetwork)
library(dplyr)

neo4j = startGraph("http://localhost:7474/db/data/", username = "neo4j")
	
nodes_query = "
MATCH (:Artigo)-[:FOI_PUBLICADO_POR]->(a:Autor) 
RETURN DISTINCT ID(a) AS id, a.nomeAutor AS label LIMIT 100
"

edges_query = "
MATCH (a1:Autor)<-[:FOI_PUBLICADO_POR]-(:Artigo)-[:FOI_PUBLICADO_POR]->(a2:Autor)
WHERE ID(a1) < 100 AND ID(a2) < 100  
RETURN ID(a1) AS from, ID(a2) AS to, COUNT(*) AS weight
"

nodes = cypher(neo4j, nodes_query)
edges = cypher(neo4j, edges_query)


nodes2_query = "
MATCH (art:Artigo)-[:FOI_PUBLICADO_POR]->(a:Autor) 
WHERE art.artigoID = 31980 OR art.artigoID = 76996
RETURN DISTINCT ID(a) AS id, a.nomeAutor AS label
"

edges2_query = "
MATCH (a1:Autor)<-[:FOI_PUBLICADO_POR]-(art:Artigo)-[:FOI_PUBLICADO_POR]->(a2:Autor)
WHERE art.artigoID = 31980 OR art.artigoID = 76996
RETURN ID(a1) AS from, ID(a2) AS to, COUNT(*) AS weight
"

nodes = cypher(neo4j, nodes2_query)
edges = cypher(neo4j, edges2_query)


a <- data.frame(unique(edges$to))
b <- data.frame(unique(edges$from))

names(a) <- "id"
names(b) <- "id"
c <- rbind(a, b)
c <- data.frame(unique(c))
names(c) <- "id"
d <- nodes[nodes$id %in% c$id, ]
nodes <- d


visNetwork(nodes, edges)

autGraph = graph.data.frame(edges, directed = FALSE, nodes)

# Run Girvan-Newman clustering algorithm
communities = edge.betweenness.community(autGraph)

# Extract cluster assignments and merge with nodes data.frame.
memb = data.frame(name = communities$names, cluster = communities$membership)
nodes = merge(nodes, memb)

nodes = nodes[c("id", "name", "cluster")]



ig = graph_from_data_frame(edges, directed=F)
nodes$value = betweenness(ig)
visNetwork(nodes, edges)

clusters = cluster_edge_betweenness(ig)
nodes$group = clusters$membership
nodes$value = NULL
visNetwork(nodes, edges)


cluster = cluster_louvain(ig)
nodes$group = clusters$membership
nodes$value = NULL
visNetwork(nodes, edges)
