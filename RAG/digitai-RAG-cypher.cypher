 
            
             CALL apoc.load.json("file:///digitai-p5.json") YIELD value AS json_data
             title: json_data. ,
             preparedBy: json_data.PREPARED_BY,
            teiSourceVersion: json_data.TEI_SOURCE_VERSION_NUMBER,
             teiSourceOutputDate: json_data.TEI_SOURCE_OUTPUT_DATE,
             thisJsonDatetime: json_data.THIS_JSON_DATETIME
             FOREACH (chapter_data IN 
            
            
            
           
            
            
            
        