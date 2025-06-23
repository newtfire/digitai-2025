import json
from neo4j import GraphDatabase
from sentence_transformers import SentenceTransformer
from framework.utils.configLoader import ConfigLoader

class HybridRetriever:
    """
    Hybrid retriever combining dense vector search with graph expansion.
    """

    def __init__(self, config: ConfigLoader):
        self.config = config

        # Neo4j connection
        self.neo4jUri = config.get('neo4j.uri')
        self.neo4jUser = config.get('neo4j.user')
        self.neo4jPassword = config.get('neo4j.password')
        self.driver = GraphDatabase.driver(self.neo4jUri, auth=(self.neo4jUser, self.neo4jPassword))

        # Embedding model (must match original embedding model used)
        print("Loading BGE-m3 embedding model for hybrid retrieval...")
        self.model = SentenceTransformer('BAAI/bge-m3')
        print("Model loaded.")

    def close(self):
        self.driver.close()

    def query(self, userQuery, topK=5):
        """
        Full hybrid query pipeline: dense similarity + graph expansion.
        """
        queryEmbedding = self.model.encode(userQuery, normalize_embeddings=True).tolist()

        with self.driver.session() as session:
            # Dense vector search (primary retrieval)
            denseResults = session.execute_read(self.vectorSearch, queryEmbedding, topK)

            # Graph expansion (secondary symbolic retrieval)
            expandedResults = []
            for result in denseResults:
                nodeId = result["id"]
                score = result["score"]
                related = session.execute_read(self.graphExpansion, nodeId)
                expandedResults.append({
                    "hit": nodeId,
                    "score": score,
                    "graphExpansion": related
                })

            return expandedResults

    @staticmethod
    def vectorSearch(tx, embedding, topK):
        """
        Dense similarity search via Neo4jVector.
        """
        query = """
        CALL db.index.vector.queryNodes('chunkEmbeddingIndex', $topK, $embedding) YIELD node, score
        RETURN node.id AS id, score
        ORDER BY score DESC
        """
        result = tx.run(query, embedding=embedding, topK=topK)
        return [{"id": record["id"], "score": record["score"]} for record in result]

    @staticmethod
    def graphExpansion(tx, paragraphId):
        """
        Symbolic graph walk starting from paragraph hit node.
        """
        query = """
        MATCH (p:Paragraph {id: $paragraphId})<-[:CONTAINS]-(sec:Section)<-[:CONTAINS]-(chap:Chapter)<-[:CONTAINS]-(part:Part)<-[:CONTAINS]-(doc:Document)
        OPTIONAL MATCH (p)-[:MENTIONS]->(entity)
        RETURN 
            doc.id AS documentId, 
            sec.id AS sectionId, 
            chap.id AS chapterId, 
            part.id AS partId,
            COLLECT(DISTINCT entity.name) AS mentionedEntities
        """
        result = tx.run(query, paragraphId=paragraphId)
        record = result.single()
        if record:
            return {
                "documentId": record["documentId"],
                "sectionId": record["sectionId"],
                "chapterId": record["chapterId"],
                "partId": record["partId"],
                "mentionedEntities": record["mentionedEntities"]
            }
        return {}