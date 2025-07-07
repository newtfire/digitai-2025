<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:my="https://my.namespace/for/function-definitions" exclude-result-prefixes="xs math"
    version="3.0">

    <xsl:variable name="sourceDoc" as="document-node()" select="doc('sandboxTest.xml')"/>
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="tab" as="xs:string" select="'&#x9;'"/>
    <xsl:variable name="nltab" as="xs:string" select="$newline || $tab"/>

    <!-- MAP FOR THE GRAPH MODEL -->
    <!-- 2025-06-30 ebb: graph model is complete for this sandbox example, but functions
    require revision! 
    -->
    <xsl:variable name="my:graph-model" as="map(xs:string, map(*))">
        <xsl:map>
            <xsl:map-entry key="'document'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Document</xsl:map-entry>
                    <xsl:map-entry key="'xpathPattern'">document()</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">doc</xsl:map-entry>
                    <xsl:map-entry key="'jsonVar'">value</xsl:map-entry>
                    <!-- ebb: Literally 'value' is the value of the document imported on load into neo4j. -->
                    <xsl:map-entry key="'primaryKey'">title</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">DOC_TITLE</xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARTS',
                                        'childEntityType': 'part',
                                        'relationship': 'HAS_PART',
                                        'isSequence': 'true()'
                                    }
                                
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'part'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Part</xsl:map-entry>
                    <xsl:map-entry key="'xpathPattern'">front | body</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">part</xsl:map-entry>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">PART</xsl:map-entry>
                 <!--   <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>-->
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_CHAPTERS',
                                        'childEntityType': 'chapter',
                                        'relationship': 'HAS_CHAPTER',
                                        'isSequence': 'true()'
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'chapter'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Chapter'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='chapter']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'chapter'"/>
                    <xsl:map-entry key="'primaryKey'" select="'chapter'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'CHAPTER'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">HEAD</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SECTIONS',
                                        'childEntityType': 'section',
                                        'relationship': 'HAS_SECTION',
                                        'isSequence': 'true()'
                                    },
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH',
                                        'isSequence': 'true()'
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>

            <xsl:map-entry key="'section'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='section']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SECTION'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">HEAD</xsl:map-entry>
                           <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SUBSECTIONS',
                                        'childEntityType': 'subsection',
                                        'relationship': 'HAS_SUBSECTION',
                                        'isSequence': 'true()'
                                    },
                                    
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH',
                                        'isSequence': 'true()'
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'subsection'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Subsection'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='section']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'subsection'"/>
                    <xsl:map-entry key="'primaryKey'" select="'subsection'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SUBSECTION'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">HEAD</xsl:map-entry>
                           <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_NESTED_SUBSECTIONS',
                            'childEntityType': 'nestedsubsection',
                            'relationship': 'HAS_NESTED_SUBSECTION',
                            'isSequence': 'true()'
                            },
                            
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': 'true()'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'nestedsubsection'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Nestedsubsection'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='section']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'nestedsubsection'"/>
                    <xsl:map-entry key="'primaryKey'" select="'nestedsubsection'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'NESTEDSUBSECTION'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">HEAD</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': 'true()'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>

            <xsl:map-entry key="'paragraph'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Para'"/>
                    <xsl:map-entry key="'xpathPattern'">p</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'paragraph'"/>
                    <xsl:map-entry key="'primaryKey'" select="'paragraph'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'PARASTRING'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                           <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SPECLISTS',
                                        'childEntityType': 'speclist',
                                        'relationship': 'HAS_SPECLIST'
                                    },
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SPECGRPS',
                                        'childEntityType': 'specgrp',
                                        'relationship': 'HAS_SPECGRP'
                                    }
                                }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'speclist'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Speclist'"/>
                    <xsl:map-entry key="'xpathPattern'">specList</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'speclist'"/>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">SPECLIST</xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map{
                                'jsonChildrenKey' : 'LINK_TO_SPEC',
                                'childEntityType': 'link_to_spec',
                                'relationship': 'REFERS_TO_SPECIFICATION'
                            }}"/>
                               
                             </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'link_to_spec'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'LinkToSpec'"/>
                    <xsl:map-entry key="'xpathPattern'">specDesc</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'link_to_spec'"/>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">LINK_TO_SPEC</xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'specgrp'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Specgrp'"/>
                    <xsl:map-entry key="'xpathPattern'">specGrp</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'specgrp'"/>
                    <xsl:map-entry key="'primaryKey'">name</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">SPECGRP</xsl:map-entry>
                    <xsl:map-entry key="'properties'" select="
                            map {
                                'title': 'SPECGRP'
                            }"/>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_SPECS',
                                        'childEntityType': 'specification',
                                        'relationship': 'HAS_SPEC'
                                    }
                                }"/>
                    </xsl:map-entry>

                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'specification'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Spec'"/>
                    <xsl:map-entry key="'xpathPattern'">spec</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'specification'"/>
                    <xsl:map-entry key="'primaryKey'" select="''"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC'"/>
                    <xsl:map-entry key="'children'">
                                <xsl:sequence select="array{
                                    map{'jsonChildrenKey': 'HAS_CONTENT',
                                        'childEntityType': 'contentmodel',
                                        'relationship': 'DEFINES_CONTENT_MODEL'},
                                    map{'jsonChildrenKey': 'CONTAINS_PARAS',
                                        'childEntityType': 'paragraph',
                                        'relationship': 'HAS_PARAGRAPH'
                                    }
                                    }"/>
                            </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'contentmodel'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Content'"/>
                    <xsl:map-entry key="'xpathPattern'">contentModel</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'contentmodel'"/>
                    <xsl:map-entry key="'primaryKey'" select="'name'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'CONTENT'"/>
                    <xsl:map-entry key="'properties'" select="map{'rule':'RULE'}"/> 
                </xsl:map>
            </xsl:map-entry>
        </xsl:map>
    </xsl:variable>


    <!-- FUNCTIONS AND TEMPLATES FOR GENERATING JSON DATA FROM SOURCE XML -->

    <xsl:function name="my:sectionMapper" as="map(*)*">
        <xsl:param name="section" as="element()+"/>
        <xsl:for-each select="$section">
            <xsl:variable name="section" as="element()?" select="current()"/>
            <xsl:map>
                <xsl:map-entry key="$section/@type ! upper-case(.)">
                    <xsl:value-of select="$section/head ! normalize-space()"/>
                </xsl:map-entry>
                <xsl:map-entry key="'SEQUENCE'">
                    <xsl:value-of select="count($section/preceding-sibling::div) + 1"/>
                </xsl:map-entry>
                <xsl:if test="$section[@xml:id]">
                    <xsl:map-entry key="'ID'">
                        <xsl:value-of select="$section/@xml:id ! normalize-space()"/>
                    </xsl:map-entry>
                </xsl:if>
                <!-- Is this a div with nested divs? If so, continue processing those subsections. -->
                <xsl:if test="$section/div">
                    <xsl:map-entry key="'CONTAINS_SECTIONS'">
                        <xsl:sequence select="
                                array {
                                    for $s in $section/div
                                    return
                                        my:sectionMapper($s)
                                }"/>
                    </xsl:map-entry>
                </xsl:if>
                <xsl:map-entry key="'CONTAINS_PARAS'">
                    <xsl:sequence select="
                            array {
                                for $p in $section/p
                                return
                                    my:paraMapper($p)
                            }"/>
                </xsl:map-entry>

            </xsl:map>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="my:paraMapper" as="map(*)*">
        <xsl:param name="para" as="element()"/>
        <xsl:map>
            <xsl:map-entry key="'PARASTRING'">
                <xsl:value-of select="$para ! normalize-space()"/>
            </xsl:map-entry>
            <xsl:map-entry key="'SEQUENCE'">
                <xsl:value-of select="count($para/preceding-sibling::p) + 1"/>
            </xsl:map-entry>
            <xsl:if test="$para/*">
                <xsl:choose>
                    <xsl:when test="$para/*[self::specGrp]">
                        <xsl:map-entry key="'CONTAINS_SPECGRPS'">
                            <xsl:sequence select="array {my:specGrpMapper($para/specGrp)}"/>
                        </xsl:map-entry>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:map-entry key="'CONTAINS_SPECLISTS'">
                            <xsl:variable name="specRefs" as="map(*)*">
                                <xsl:for-each select="$para//specDesc">
                                    <xsl:map>
                                        <xsl:map-entry key="'LINK_TO_SPEC'">
                                            <xsl:value-of
                                                select="current()/@key ! normalize-space()"/>
                                        </xsl:map-entry>
                                    </xsl:map>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:sequence select="map{ 'SPECLIST': array {$specRefs}}"/>
                        </xsl:map-entry>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:map>
    </xsl:function>

    <xsl:function name="my:specGrpMapper" as="map(*)*">
        <xsl:param name="specGrp" as="element()"/>
        <xsl:variable name="specs" as="element()+" select="$specGrp/spec"/>
        <xsl:variable name="specMaps" as="map(*)*">
            <xsl:for-each select="$specs">
            <xsl:map>
                <xsl:map-entry key="'SPEC'">
                    <xsl:value-of select="current()/@ident ! normalize-space()"/>
                </xsl:map-entry>
                <xsl:if test="current()/p">
                    <xsl:map-entry key="'CONTAINS-PARAS'">
                        <xsl:sequence select="
                                for $p in current()/p
                                return
                                    my:paraMapper($p)"/>
                    </xsl:map-entry>
                </xsl:if>
                <xsl:map-entry key="'CONTENT'">
                    <xsl:sequence select="current()/contentModel ! name()"/>
                </xsl:map-entry>
            </xsl:map>
        </xsl:for-each>
        </xsl:variable>
        <xsl:map>
            <xsl:map-entry key="'SPECGRP'" select="array{$specMaps}"/>
        </xsl:map>
    </xsl:function>

    <xsl:template match="/">
        <xsl:result-document href="sandboxTest.json" method="json" indent="yes">
            <xsl:map>
                <xsl:map-entry key="'DOC_TITLE'">SOURCE XML AS BASIS FOR A KNOWLEDGE
                    GRAPH</xsl:map-entry>
                <xsl:variable name="parts" as="map(*)*">
                    <xsl:for-each select="$sourceDoc/*/*">
                        <xsl:map>
                            <xsl:map-entry key="'PART'">
                                <xsl:sequence select="current() ! name() ! normalize-space()"/>
                            </xsl:map-entry>
                            <xsl:map-entry key="'SEQUENCE'">
                                <xsl:choose>
                                    <xsl:when test="current() ! name() = 'front'">
                                        <xsl:value-of select="1"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="2"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:map-entry>
                            <xsl:map-entry key="'CONTAINS_CHAPTERS'">
                                <xsl:sequence select="array {my:sectionMapper(current()/div)}"/>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:map-entry key="'CONTAINS_PARTS'">
                    <xsl:sequence select="array {$parts}"/>
                </xsl:map-entry>

            </xsl:map>
        </xsl:result-document>
        <xsl:apply-templates select="/" mode="cypher"/>
    </xsl:template>

    <!-- CYPHER MAP, FUNCTIONS AND TEMPLATES FOR IMPORTING THE JSON AND BUILDING THE GRAPH -->

    <!-- FUNCTION TO CREATE GRAPH NODES -->
    <xsl:function name="my:generate-node-statement" as="xs:string">
        <xsl:param name="current-entity-type" as="xs:string"/>
        <xsl:param name="current-json-var" as="xs:string"/>
        <xsl:param name="current-json-pk" as="xs:string"/>

        <xsl:variable name="model" select="$my:graph-model($current-entity-type)"/>
        <xsl:variable name="label" select="$model('label')"/>
        <xsl:variable name="cypher-var" as="xs:string" select="$model('cypherVar') ! string()"/>


        <xsl:variable name="node-clause" as="xs:string">
            <xsl:choose>
                <xsl:when test="map:contains($model, 'primaryKey')">
                    <xsl:variable name="current-cypher-pk" as="xs:string" select="$model('primaryKey') ! string()"/>
                    <xsl:sequence select="
                            'MERGE (' || $current-entity-type || ':' || $label ||
                            ' {' || $current-cypher-pk || ': ' || $current-entity-type||'_data'||'.' || $model('jsonKeyForPK') || '})'
                            "/>
                </xsl:when>
                <xsl:otherwise>
                    
                    <xsl:sequence select="
                            'CREATE (' || $cypher-var || ':' || $model('label') || ')'
                            "/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
       <xsl:variable name="set-clauses" as="xs:string*">
            <xsl:if test="map:contains($model, 'properties')">
                <xsl:variable name="properties-map" select="$model('properties')"/>
                <xsl:for-each select="map:keys($properties-map)">
                    <xsl:variable name="prop-key" select="."/>
                    <xsl:variable name="json-key" select="$properties-map($prop-key)"/>
                    <xsl:sequence
                        select="$cypher-var || '.' || $prop-key || ' = ' || $current-json-var || '.' || $json-key"
                    />
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="full-set-statement" as="xs:string"
            select="string-join($set-clauses, ', ')"/> 
        <xsl:sequence select="
                if (exists($set-clauses))
                then
                    $node-clause || ' SET ' || $full-set-statement
                else
                    $node-clause
                "/>
    </xsl:function>
    
    <!-- FUNCTION TO ESTABLISH A SINGLE FOREACH STATEMENT (ONE FOR EACH CHILDTYPE OF A NODE) -->
    <!-- ebb: Fire this function while looking down at the children while processing the current node. -->
    <xsl:function name="my:generate-foreach-statement" as="xs:string">
        <xsl:param name="child-type" as="xs:string"/>
        <xsl:param name="parent-json-var" as="xs:string"/>
        <xsl:param name="json-children-key" as="xs:string"/><!-- ebb: for example: "CONTAINS_PARTS"  -->
        <xsl:value-of select="$nltab||'FOREACH ('||$child-type||'_data'||' IN '||$parent-json-var||'.'||$json-children-key||' |'||$nltab"/>
    </xsl:function>


    <!-- FUNCTION TO ESTABLISH EACH GRAPH EDGES (RELATIONSHIP CONNECTIONS)-->
    <xsl:function name="my:generate-relationship-merge" as="xs:string+">
        <xsl:param name="child-cypher-var" as="xs:string"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="relationship-name" as="xs:string"/>
   

        <xsl:sequence select="
                'MERGE (' || $parent-cypher-var || ')-[:' || $relationship-name || ']->(' || $child-cypher-var || ')'
                "/>
    </xsl:function>

    <!-- FUNCTION FOR PROCESSING SEQUENCES OF SIBLINGS  -->
    <xsl:function name="my:create-next-links" as="xs:string*">
        <xsl:param name="child-entity" as="xs:string"/>
        <xsl:param name="sort-property" as="xs:string"/>
        <!--ebb:
            We expect to read properties of a 'children' map here, if they are in sequence.
            $sort-property will just be 'sequence'. (Refactor child maps accordingly.)
            Also, this expects to be seeing the capitalized cypher node name (e.g. 'Part'). 
        -->
        <xsl:variable name="node-label" as="xs:string" select="$my:graph-model($child-entity)?label"/> 
        
        <xsl:sequence>
            <xsl:value-of select="$newline, '// Link sequential :', $node-label, ' nodes', $newline"/>
            <xsl:variable name="cypher" as="xs:string" select="
                $tab||'MATCH (n:'||$node-label||')'||$nltab||
                $tab||'WHERE n.'||$sort-property||' IS NOT NULL'||$nltab||
                $tab||'WITH n.'||$sort-property||', n'||$nltab||
                $tab||'ORDER BY n.'||$sort-property||$nltab||
                $tab||'WITH collect(n) AS ordered_nodes'||$nltab||
                $tab||'UNWIND range(0, size(ordered_nodes) - 2) AS i'||$nltab||
                $tab||$tab||'WITH ordered_nodes[i] AS n1, ordered_nodes[i+1] AS n2'||$nltab||
                $tab||$tab||'MERGE (n1)-[:NEXT]->(n2)'||$nltab
                "/>
            <xsl:sequence select="$cypher"/>
        </xsl:sequence>
    </xsl:function>
    
  
    
    <!-- GENERATE CYPHER FROM THE SOURCE XML AND OUR GRAPH MODEL VARIABLE AT THE TOP OF THIS FILE -->
  

    <xsl:template match="/" mode="cypher">
        <xsl:variable name="currentXMLNode" as="document-node()" select="current()"/>
        <xsl:result-document href="sandbox-cypher-import.cypher" method="text">
            
            <!-- ebb: Define the variables in the graph model where the cypher script processing must begin. 
            Presumably it's the document mode, so that is what we've set here.-->
            <xsl:variable name="root-entity-type"  as="xs:string" select="'document'"/>
            <xsl:variable name="root-model" select="$my:graph-model($root-entity-type)"/>
            <xsl:variable name="root-cypher-var" select="$root-model('cypherVar') ! string()" as="xs:string"/>
            <xsl:variable name="root-json-var" select="$root-model('jsonVar') ! string()"/>
            <xsl:variable name="root-pk" select="$root-model('primaryKey') ! string()"/>
            <xsl:variable name="root-json-pk" select="$root-model('jsonKeyForPK') ! string()"/>

            <xsl:text>
// ==== Generated by XSLT Transformation ====

// 1. SETUP: Create Constraints for Performance and Data Integrity
 CREATE CONSTRAINT IF NOT EXISTS FOR (d:Document) REQUIRE d.title IS UNIQUE;
 CREATE CONSTRAINT IF NOT EXISTS FOR (s:Section) REQUIRE s.id IS UNIQUE;
 CREATE CONSTRAINT IF NOT EXISTS FOR (spec:Specification) REQUIRE spec.name IS UNIQUE;

// 2. LOAD AND PROCESS: Load the JSON and start the recursive import
CALL apoc.load.json("file:///sandboxTest.json") YIELD value

// Create the root Document node
MERGE (doc:Document {title: 'SOURCE XML AS BASIS FOR A KNOWLEDGE GRAPH'})

</xsl:text>

            <xsl:if test="map:contains($root-model, 'children')">
                <xsl:for-each select="$root-model?children?*"> 
                    <!-- ebb: child-type is the entity name for the child that we use in our graph-map in this XSLT.
                    It's included in the children map entry for each map that has children to facilitate linkage  -->
                    <xsl:variable name="child-type" as="xs:string" select="current()('childEntityType') ! string()"/>
                    <!-- ebb: just calculate the child-json-name (block-cap the entity name) -->
                    <xsl:variable name="child-json-name" as="xs:string" select="$child-type ! upper-case(.)"/>
                    <!-- ebb: json-children-key: For example, 'CONTAINS_PARTS' (plural) -->
                    <xsl:variable name="json-children-key" as="xs:string" select="current()('jsonChildrenKey') ! string()"/>
                    <!-- ebb: relationship: For example, 'HAS_PART' (singular): 
                       Pass this information down as a parameter to the next template that processes the children one by one. -->  
                    <xsl:variable name="relationship" as="xs:string" select="current()('relationship') ! string()"/>
                    
                
             <!--  TO DEVELOP FOR ESTABLISHING SEQUENCES
                     <xsl:if test="map:contains(current()('isSequence'))">
                        <xsl:variable name="sequence" as="xs:string" select="current()('isSequence')"/>
                    </xsl:if>-->
                    
               <xsl:sequence select="my:generate-foreach-statement($child-type, $root-json-var, $json-children-key)"/>
                    
                    
               <xsl:apply-templates select="$currentXMLNode//front | $currentXMLNode//body" mode="cypher">
                   <xsl:with-param name="parent-context-node" as="document-node()" select="$currentXMLNode"/>
                   <xsl:with-param name="parent-cypher-var" as="xs:string" select="$root-cypher-var"/>
                   <xsl:with-param name="map-entity-to-process" as="xs:string*" select="$child-type"/>
                   <xsl:with-param name="parent-child-relationship" as="xs:string" select="$relationship"/>
                </xsl:apply-templates>
                    
                  <xsl:sequence select="my:create-next-links($child-type, 'sequence')"/>
                </xsl:for-each>
        </xsl:if>

        </xsl:result-document>
    </xsl:template>
    <xsl:template match="front | body" mode="cypher">
        <xsl:param name="parent-context-node" as="document-node()"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="map-entity-to-process" as="xs:string*"/>
        <xsl:param name="parent-child-relationship" as="xs:string"/>
        
        <xsl:variable name="current-context-node" as="element()" select="current()"/>
        <xsl:variable name="current-entity-type"  as="xs:string" select="$map-entity-to-process"/>
        <xsl:variable name="current-model" select="$my:graph-model($current-entity-type)"/>
        <xsl:variable name="current-cypher-var" select="$current-model('cypherVar') ! string()" as="xs:string"/>
      <!-- <xsl:variable name="current-json-var" select="$current-model('jsonVar') ! string()"/>-->
        <xsl:variable name="current-pk" select="$current-model('primaryKey') ! string()"/>
        <xsl:variable name="current-json-pk" select="$current-model('jsonKeyForPK') ! string()"/>
   
      <xsl:if test="current() = $parent-context-node//*[self::front | self::body][last()]">  
          <xsl:sequence select="my:generate-node-statement($current-entity-type, $current-pk, $current-json-pk), $nltab, $nltab"/>
          <xsl:sequence select="my:generate-relationship-merge($current-cypher-var, $parent-cypher-var, $parent-child-relationship), $nltab"/>
          <xsl:if test="map:contains($current-model, 'children')">
            <xsl:for-each select="$current-model?children?*"> 
                <!-- ebb: child-type is the entity name for the child that we use in our graph-map in this XSLT.
                    It's included in the children map entry for each map that has children to facilitate linkage  -->
                <xsl:variable name="child-type" as="xs:string" select="current()('childEntityType') ! string()"/>
                <!-- ebb: just calculate the child-json-name (block-cap the entity name) -->
                <xsl:variable name="child-json-name" as="xs:string" select="$child-type ! upper-case(.)"/>
                <!-- ebb: json-children-key: For example, 'CONTAINS_PARTS' (plural) -->
                <xsl:variable name="json-children-key" as="xs:string" select="current()('jsonChildrenKey') ! string()"/>
                <!-- ebb: relationship: For example, 'HAS_PART' (singular): 
                       Pass this information down as a parameter to the next template that processes the children one by one. -->  
                <xsl:variable name="relationship" as="xs:string" select="current()('relationship') ! string()"/>
                <xsl:sequence select="my:generate-foreach-statement($child-type, $current-json-pk, $json-children-key)"/>
    
               <xsl:call-template name="processChildren">
                    <xsl:with-param name="child-context-node" as="element()+" select="$current-context-node/*"/>
                    <xsl:with-param name="parent-context-node" as="element()" select="$current-context-node"/>
                    <xsl:with-param name="parent-cypher-var" as="xs:string" select="$current-cypher-var"/>
                    <xsl:with-param name="map-entity-to-process" as="xs:string*" select="$child-type"/>
                    <xsl:with-param name="parent-child-relationship" as="xs:string" select="$relationship"/>
                </xsl:call-template>   
                <xsl:sequence select="my:create-next-links($child-type, 'sequence')"/>
            </xsl:for-each>
        </xsl:if>
      </xsl:if>
    </xsl:template>
    
    <!-- ebb: NAMED TEMPLATE FOR PROCESSING CHILDREN -->
    <xsl:template name="processChildren">
        <xsl:param name="child-context-node" as="element()+"/>
        <xsl:param name="parent-context-node" as="element()"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="map-entity-to-process" as="xs:string"/>
        <xsl:param name="parent-child-relationship" as="xs:string"/>
        
        <xsl:variable name="current-context-node" as="element()+" select="$child-context-node"/>
        <xsl:variable name="current-model" select="$my:graph-model($map-entity-to-process)"/>
        <xsl:variable name="current-cypher-var" select="$current-model('cypherVar') ! string()" as="xs:string"/>
        <xsl:variable name="current-json-var" select="$current-model('jsonVar') ! string()"/>
        <xsl:variable name="current-pk" select="$current-model('primaryKey') ! string()"/>
        <xsl:variable name="current-json-pk" select="$current-model('jsonKeyForPK') ! string()"/>
        
        <!-- ebb: find the distinct-values of the child-context-nodes delivered to this template. -->
        <xsl:variable name="distinctChildNames" as="xs:string+" select="distinct-values($child-context-node ! name())"/>
        
        <xsl:for-each select="$distinctChildNames">
            <xsl:variable name="AllChildElemsWithThisName" as="element()*" select="$parent-context-node/*[name() = current()]"/>
            <xsl:if test="($AllChildElemsWithThisName)[last()]">
               
                <xsl:sequence select="my:generate-node-statement($map-entity-to-process, $current-pk, $current-json-pk), $nltab, $nltab"/>
                <xsl:sequence select="my:generate-relationship-merge($current-cypher-var, $parent-cypher-var, $parent-child-relationship), $nltab"/>
                
      
                <xsl:if test="$AllChildElemsWithThisName[*]">
                    <xsl:for-each select="$current-model('children')?*"> 
                     
                        <!-- ebb: child-type is the entity name for the child that we use in our graph-map in this XSLT.
                    It's included in the children map entry for each map that has children to facilitate linkage  -->
                        <xsl:variable name="child-type" as="xs:string" select="current()('childEntityType') ! string()"/>
                        <!-- ebb: just calculate the child-json-name (block-cap the entity name) -->
                        <xsl:variable name="child-json-name" as="xs:string" select="$child-type ! upper-case(.)"/>
                        <!-- ebb: json-children-key: For example, 'CONTAINS_PARTS' (plural) -->
                        <xsl:variable name="json-children-key" as="xs:string?" select="current()('jsonChildrenKey') ! string()"/>
                        <xsl:message><xsl:value-of select="$json-children-key"/></xsl:message>
                        <!-- ebb: relationship: For example, 'HAS_PART' (singular): 
                       Pass this information down as a parameter to the next template that processes the children one by one. -->  
                        <xsl:variable name="relationship" as="xs:string" select="current()('relationship') ! string()"/>
                        <xsl:sequence select="my:generate-foreach-statement($child-type, $current-json-pk, ($json-children-key,'NONE')[1])"/>
                        
                        <xsl:if test="$AllChildElemsWithThisName/*"> 
                           <xsl:call-template name="processChildren">
                            <xsl:with-param name="child-context-node" as="element()+" select="$AllChildElemsWithThisName/*"/>
                               <xsl:with-param name="parent-context-node" as="element()" select="($AllChildElemsWithThisName[*][count(descendant::* ! name() => distinct-values())  = count(descendant::* ! name() => distinct-values())  => max()])[1]"/>
                            <!-- ebb: Trying to isolate the node with the max depth: [last()] -->
                            <xsl:with-param name="parent-cypher-var" as="xs:string" select="$current-cypher-var"/>
                            <xsl:with-param name="map-entity-to-process" as="xs:string*" select="$child-type"/>
                            <xsl:with-param name="parent-child-relationship" as="xs:string" select="$relationship"/>
                        </xsl:call-template>  </xsl:if>
                       
                        <xsl:if test="map:contains(current(), 'isSequence')">
                            <xsl:sequence select="my:create-next-links($child-type, 'sequence')"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
       
            </xsl:if>
        </xsl:for-each>
 
    </xsl:template>


</xsl:stylesheet>
