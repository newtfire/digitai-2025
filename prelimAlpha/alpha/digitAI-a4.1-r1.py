from crewai_tools import XMLSearchTool

# Allow agents to search within any XML file's content
#as it learns about their paths during execution
tool = XMLSearchTool()

# OR

# Initialize the tool with a specific XML file path
#for exclusive search within that document
tool = XMLSearchTool(xml='path/to/your/xmlfile.xml')

tool = XMLSearchTool(
    config=dict(
        llm=dict(
            provider="ollama", # or google, openai, anthropic, llama2, ...
            config=dict(
                model="llama2",
                # temperature=0.5,
                # top_p=1,
                # stream=true,
            ),
        ),
        embedder=dict(
            provider="google", # or openai, ollama, ...
            config=dict(
                model="models/embedding-001",
                task_type="retrieval_document",
                # title="Embeddings",
            ),
        ),
    )
)