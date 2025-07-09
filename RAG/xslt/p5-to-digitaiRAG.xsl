<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg="http://www.tei-c.org/ns/Examples" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:nf="http://newtfire.org"
    exclude-result-prefixes="xs math" version="3.0">



    <!--GLOBAL VARIABLES -->
    <xsl:variable name="currentDateTime" as="xs:string" select="current-dateTime() ! string()"/>
    <xsl:variable name="P5" as="document-node()" select="doc('../p5.xml')"/>
    <xsl:variable name="P5-version" as="xs:string" select="$P5//edition/ref[2] ! normalize-space()"/>
    <xsl:variable name="P5-versionDate" as="xs:string"
        select="$P5//edition/date/@when ! normalize-space()"/>
    
    <xsl:variable name="newline" as="xs:string" select="'&#10;'"/>
    <xsl:variable name="tab" as="xs:string" select="'&#x9;'"/>
    <xsl:variable name="nltab" as="xs:string" select="$newline || $tab"/>

    <xsl:variable name="nf:graph-model" as="map(*)*">
        <xsl:map>
            <xsl:map-entry key="'document'">
                <xsl:map>
                    <xsl:map-entry key="'label'">Document</xsl:map-entry>
                    <xsl:map-entry key="'xpathPattern'">document()</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'">doc</xsl:map-entry>
                    <xsl:map-entry key="'jsonVar'">value</xsl:map-entry>
                    <!-- ebb: Literally 'value' is the value of the document imported on load into neo4j. -->
                    <xsl:map-entry key="'primaryKey'">title</xsl:map-entry>
                    <xsl:map-entry key="'jsonKeyForPK'">DOCUMENT_TITLE</xsl:map-entry>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'jsonDateTime'">THIS_JSON_DATETIME</xsl:map-entry>
                            <xsl:map-entry key="'teiSourceDate'">TEI_SOURCE_OUTPUT_DATE</xsl:map-entry>
                            <xsl:map-entry key="'teiSourceVersion'">TEI_SOURCE_VERSION_NUMBER</xsl:map-entry>
                            <xsl:map-entry key="'supportInst'">SUPPORTING_INSTITUTION</xsl:map-entry>
                            <xsl:map-entry key="'byline'">PREPARED_BY</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                                array {
                                    map {
                                        'jsonChildrenKey': 'CONTAINS_PARTS',
                                        'childEntityType': 'part',
                                        'relationship': 'HAS_PART',
                                        'isSequence': true()
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
                    <xsl:map-entry key="'properties'">
                        <xsl:map><!-- OUTPUT SEQUENCE VALUES IN JSON-DATA -->
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_CHAPTERS',
                            'childEntityType': 'chapter',
                            'relationship': 'HAS_CHAPTER',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'chapter'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Chapter'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div1']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'chapter'"/>
                    <xsl:map-entry key="'primaryKey'" select="'chapter_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">CHAPTER</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_SECTIONS',
                            'childEntityType': 'section',
                            'relationship': 'HAS_SECTION',
                            'isSequence': true()
                            },
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'section'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section_1'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div2']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section_1'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_SUBSECTIONS',
                            'childEntityType': 'section_2',
                            'relationship': 'HAS_SUBSECTION',
                            'isSequence': true()
                            },

                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            },
                            map {
                            'jsonChildrenKey': 'TEI_ENCODING_DISCUSSED.CONTAINS_SPECGRPS',
                            'childEntityType' : 'specgrp',
                            'relationship': 'HAS_SPECGRP'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'section_2'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section_2'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div2']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section_2'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_SUBSECTIONS',
                            'childEntityType': 'section_3',
                            'relationship': 'HAS_SUBSECTION',
                            'isSequence': true()
                            },
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            },
                            map {
                            'jsonChildrenKey': 'TEI_ENCODING_DISCUSSED.CONTAINS_SPECGRPS',
                            'childEntityType' : 'specgrp',
                            'relationship': 'HAS_SPECGRP'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'section_3'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Section_3'"/>
                    <xsl:map-entry key="'xpathPattern'">div[@type='div2']</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'section_3'"/>
                    <xsl:map-entry key="'primaryKey'" select="'section_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'title'">SECTION</xsl:map-entry>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO.SECTION'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                            array {
                            map {
                            'jsonChildrenKey': 'CONTAINS_PARAS',
                            'childEntityType': 'paragraph',
                            'relationship': 'HAS_PARAGRAPH',
                            'isSequence': true()
                            },
                            map {
                            'jsonChildrenKey': 'TEI_ENCODING_DISCUSSED.CONTAINS_SPECGRPS',
                            'childEntityType' : 'specgrp',
                            'relationship': 'HAS_SPECGRP'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'paragraph'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Para'"/>
                    <xsl:map-entry key="'xpathPattern'">p[*]</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'paragraph'"/>
                    <xsl:map-entry key="'primaryKey'" select="'parastring'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'PARASTRING'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO.SECTION'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'elements_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.ELEMENTS_MENTIONED'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ELEMENT_NAME'"/>
                                    <!-- EBB: Should we change this to match the name we give in an elementSpec? -->
                                </xsl:map>
                            </xsl:map-entry> 
                            <xsl:map-entry key="'attributes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.ATTRIBUTES_MENTIONED'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ATTRIBUTE_NAME'"/>
                                    <!-- EBB: Should we change this to match the name we give in a classSpec / attribute definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <!-- idents_mentioned: 11 different JSON keys -->
                            <xsl:map-entry key="'modules_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.MODULES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'MODULE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'classes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.CLASSES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'CLASS'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'files_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.FILES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'FILE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'datatypes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.DATATYPES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'DATATYPE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'macros_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.MACROS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'MACRO'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'ns_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.NSS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'NS'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'schemas_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.SCHEMAS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'SCHEMA'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'parameter_entities_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.PES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'PE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'parameter_entities_mentioned_ge'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.PES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'GE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'frags_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.FRAGS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'FRAG'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'relaxng_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.RNGS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'RNG'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'speclist_links'">
                                <!-- ebb: We were not processing these before, but I experimented with something similar in my xslt Sandbox.
                                <specList> elements contain just one kind of element child: <specDesc>
                                The <specList> can be children of <p>, or descendants of <p> (within a list[@type='gloss']/item)
                                The <specDesc> children have a @key that points to the ID of a spec, like so:
                                <specList>
                                      <specDesc key="correction" atts="status method"/>
                                </specList>
                                -->
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.CONTAINS_SPECLISTS.SPECLIST'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="
                           array{
                            map{ 
                            'jsonChildrenKey': 'TEI_ENCODING_DISCUSSED.CONTAINS_EXAMPLES',
                            'childEntityType': 'example',
                            'relationship': 'HAS_EXAMPLE'
                            },
                            map {
                            'jsonChildrenKey': 'TEI_ENCODING_DISCUSSED.CONTAINS_SPECGRPS',
                            'childEntityType' : 'specgrp',
                            'relationship': 'HAS_SPECGRP'
                            }
                            }"/>
                    </xsl:map-entry>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'example'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Example'"/>
                    <xsl:map-entry key="'xpathPattern'">eg:egXML</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'example'"/>
                    <xsl:map-entry key="'primaryKey'" select="'example'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'EXAMPLE'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'language'">LANGUAGE</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                    <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map {
                            'jsonChildrenKey': 'CONTAINS_END_PARAS',
                            'childEntityType': 'terminal_paragraph',
                            'relationship': 'HAS_END_PARAGRAPH',
                            'isSequence': true()
                            }
                            
                            }"/>   
                    </xsl:map-entry>
                </xsl:map>  
            </xsl:map-entry>
            <xsl:map-entry key="'terminal_paragraph'">
                <!-- THIS MODEL ENTRY IS FOR PARAGRAPHS THAT MAY NOT CONTAIN MEMBERS OF THIS GRAPH THAT THEMSELVES 
                CONTAIN PARAGRAPHS. -->
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'TerminalPara'"/>
                    <xsl:map-entry key="'xpathPattern'">p[not(*)]</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'paragraph'"/>
                    <xsl:map-entry key="'primaryKey'" select="'parastring'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'PARASTRING'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'sequence'">SEQUENCE</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO.SECTION'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'elements_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.ELEMENTS_MENTIONED'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ELEMENT_NAME'"/>
                                    <!-- EBB: Should we change this to match the name we give in an elementSpec? -->
                                </xsl:map>
                            </xsl:map-entry> 
                            <xsl:map-entry key="'attributes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.ATTRIBUTES_MENTIONED'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ATTRIBUTE_NAME'"/>
                                    <!-- EBB: Should we change this to match the name we give in a classSpec / attribute definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <!-- idents_mentioned: 11 different JSON keys -->
                            <xsl:map-entry key="'modules_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.MODULES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'MODULE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'classes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.CLASSES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'CLASS'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'files_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.FILES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'FILE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'datatypes_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.DATATYPES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'DATATYPE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'macros_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.MACROS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'MACRO'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'ns_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.NSS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'NS'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'schemas_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.SCHEMAS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'SCHEMA'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'parameter_entities_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.PES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'PE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'parameter_entities_mentioned_ge'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.PES_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'GE'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'frags_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.FRAGS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'FRAG'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'relaxng_mentioned'">
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.RNGS_MENTIONED'"/>
                                    <!-- EBB: UPDATE THE FUNCTION THAT OUTPUTS THESE ^^^^^^^ -->
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'RNG'"/>
                                    <!-- EBB: Should we change this to match the name we give in a *Spec definition? -->
                                </xsl:map>
                            </xsl:map-entry>
                            <xsl:map-entry key="'speclist_links'">
                                <!-- ebb: We were not processing these before, but I experimented with something similar in my xslt Sandbox.
                                <specList> elements contain just one kind of element child: <specDesc>
                                The <specList> can be children of <p>, or descendants of <p> (within a list[@type='gloss']/item)
                                The <specDesc> children have a @key that points to the ID of a spec, like so:
                                <specList>
                                      <specDesc key="correction" atts="status method"/>
                                </specList>
                                -->
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'TEI_ENCODING_DISCUSSED.CONTAINS_SPECLISTS.SPECLIST'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                   <!-- ebb: terminal_paragraph definition must NOT contain 'children' map.  -->
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'specgrp'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'Specgrp'"/>
                    <xsl:map-entry key="'xpathPattern'">specGrp</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'specgrp'"/>
                    <xsl:map-entry key="'primaryKey'" select="'specgrp_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SPECGRP_ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'name'">SPECGRP_NAME</xsl:map-entry>
                            <xsl:map-entry key="'links'">
                                <!-- THIS SHOULD PICK UP SPECGRPREF TARGETS  -->
                                <xsl:map>
                                    <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                    <xsl:map-entry key="'sourceArrayPath'" select="'RELATES_TO'"/>
                                    <xsl:map-entry key="'sourcePropertyKey'" select="'ID'"/>
                                </xsl:map>
                            </xsl:map-entry>
                            </xsl:map>
                        </xsl:map-entry>
                     <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{
                            map{
                                'jsonChildrenKey' : 'CONTAINS_SPECS',
                                'childEntityType': 'spec',
                                'relationship': 'HAS_SPEC'
                            }
                            }"/>
                    </xsl:map-entry>            
                </xsl:map>
            </xsl:map-entry>
       <xsl:map-entry key="'spec'">
               <xsl:map> 
                 <xsl:map-entry key="'label'" select="'Specification'"/>
                <xsl:map-entry key="'xpathPattern'">spcGrp/*[name() ! ends-with(., 'Spec')]</xsl:map-entry>
                <xsl:map-entry key="'cypherVar'" select="'spec'"/>
                <xsl:map-entry key="'primaryKey'" select="'spec_id'"/>
                <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC_ID'"/>
                <xsl:map-entry key="'properties'">
                    <xsl:map>
                        <xsl:map-entry key="'spec_type'">SPEC_TYPE</xsl:map-entry>
                        <xsl:map-entry key="'module'">PART_OF_MODULE</xsl:map-entry>
                        <xsl:map-entry key="'class'">MEMBER_OF_CLASS</xsl:map-entry>
                        <xsl:map-entry key="'equiv_name'">EQUIVALENT_NAME</xsl:map-entry>
                        <xsl:map-entry key="'glosses'">
                            <xsl:map>
                                <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                <xsl:map-entry key="'sourceArrayPath'" select="'GLOSSED_BY'"/>
                                <xsl:map-entry key="'sourcePropertyKey'" select="'GLOSS'"/>
                            </xsl:map>
                        </xsl:map-entry>
                        <xsl:map-entry key="'descriptions'">
                            <xsl:map>
                                <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                <xsl:map-entry key="'sourceArrayPath'" select="'DESCRIBED_BY'"/>
                                <xsl:map-entry key="'sourcePropertyKey'" select="'DESC'"/>
                            </xsl:map>
                        </xsl:map-entry>
                        <xsl:map-entry key="'remarks'">
                            <xsl:map>
                                <xsl:map-entry key="'isListComprehension'" select="true()"/>
                                <xsl:map-entry key="'sourceArrayPath'" select="'REMARKS_ON'"/>
                                <xsl:map-entry key="'sourcePropertyKey'" select="'REMARK'"/>
                            </xsl:map>
                        </xsl:map-entry>
                    </xsl:map>
                </xsl:map-entry>
                <xsl:map-entry key="'children'">
                    <xsl:sequence select="array{ 
                        map{ 
                        'jsonChildrenKey': 'CONTAINS_CONTENT_MODEL',
                        'childEntityType': 'content_model',
                        'relationship': 'CONTENT_MODEL'
                         }
                      (:   map{ 
                         'jsonChildrenKey': 'LISTS_ATTRIBUTES',
                         'childEntityType': 'attribute',
                         'relationship': 'HAS_ATTRIBUTE'
                         },
                         map{ 
                         'jsonChildrenKey': 'CONSTRAINED_BY',
                         'childEntityType': 'constraint',
                         'relationship': 'HAS_CONSTRAINT'
                         },
                         map{ 
                         'jsonChildrenKey': 'CONTAINS_EXAMPLES',
                         'childEntityType': 'example',
                         'relationship': 'HAS_EXAMPLE'
                         } :)
                        }"/>
                </xsl:map-entry>                  
               </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'content_model'">
                <xsl:map>
                    <xsl:map-entry key="'label'" select="'ContentModel'"/>
                    <xsl:map-entry key="'xpathPattern'">content</xsl:map-entry>
                    <xsl:map-entry key="'cypherVar'" select="'content_model'"/>
                    <xsl:map-entry key="'primaryKey'" select="'spec_id'"/>
                    <xsl:map-entry key="'jsonKeyForPK'" select="'SPEC_ID'"/>
                    <xsl:map-entry key="'properties'">
                        <xsl:map>
                            <xsl:map-entry key="'textnode'">TEXTNODE</xsl:map-entry>
                            <xsl:map-entry key="'empty'">EMPTY</xsl:map-entry>
                        </xsl:map>
                    </xsl:map-entry>
                   <!-- <xsl:map-entry key="'children'">
                        <xsl:sequence select="array{ 
                            map { 
                            'jsonChildrenKey' : 'CONTAINS_ALTERNATING_CONTENTS',
                            'childEntityType' : 'alternate',
                            'relationship' : 'ALTERNATING'
                            },
                            map { 
                            'jsonChildrenKey' : 'CONTAINS_SEQUENTIAL_CONTENTS',
                            'childEntityType' : 'sequence',
                            'relationship' : 'SEQUENCE',
                            'isSequence': true()
                            },
                            map { 
                            'jsonChildrenKey' : 'CONTAINS_VALLIST',
                            'childEntityType' : 'vallist',
                            'relationship' : 'HAS_VAL'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_DATAREF',
                            'childEntityType': 'dataref',
                            'relationship': 'HAS_DATAREF'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_MACROREF',
                            'childEntityType': 'macroref',
                            'relationship': 'HAS_MACROREF'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_CLASSREF',
                            'childEntityType': 'classref',
                            'relationship': 'HAS_CLASSREF'
                            },
                            map{ 
                            'jsonChildrenKey': 'CONTAINS_ELEMENTREF',
                            'childEntityType': 'elementref',
                            'relationship': 'HAS_ELEMENTREF'
                            }
                            }"/>
                    </xsl:map-entry>-->
      
                </xsl:map> 
            </xsl:map-entry>
            <!-- <xsl:map-entry key="'alternate'">
                        
                        
                    </xsl:map-entry>-->
        </xsl:map>
    </xsl:variable>



    <!-- JSON MAPPING TO KEYS -->
    <!-- GRAPH NODE KEYS -->
    <xsl:variable name="DOCUMENT_TITLE" as="xs:string" select="'DOCUMENT_TITLE'"/>
    <xsl:variable name="PREPARED_BY" as="xs:string" select="'PREPARED_BY'"/>
    <xsl:variable name="SUPPORTING_INSTITUTION" as="xs:string" select="'SUPPORTING_INSTITUTION'"/>
    <xsl:variable name="TEI_SOURCE_VERSION_NUMBER" as="xs:string"
        select="'TEI_SOURCE_VERSION_NUMBER'"/>
    <xsl:variable name="TEI_SOURCE_OUTPUT_DATE" as="xs:string" select="'TEI_SOURCE_OUTPUT_DATE'"/>
    <xsl:variable name="THIS_JSON_DATETIME" as="xs:string" select="'THIS_JSON_DATETIME'"/>
    <xsl:variable name="PART" as="xs:string" select="'PART'"/>
    <xsl:variable name="CHAPTER" as="xs:string" select="'CHAPTER'"/>
    <xsl:variable name="SUBSECTION" as="xs:string" select="'SUBSECTION'"/>
    <xsl:variable name="NAME" as="xs:string" select="'NAME'"/>
    <xsl:variable name="ID" as="xs:string" select="'ID'"/>

    <!-- SEQUENCE INDICATORS -->
    <xsl:variable name="CONTAINS_PARTS" as="xs:string" select="'CONTAINS_PARTS'"/>
    <xsl:variable name="CONTAINS_CHAPTERS" as="xs:string" select="'CONTAINS_CHAPTERS'"/>
    <xsl:variable name="CONTAINS_SECTIONS" as="xs:string" select="'CONTAINS_SECTIONS'"/>
    <xsl:variable name="CONTAINS_SUBSECTIONS" as="xs:string" select="'CONTAINS_SUBSECTIONS'"/>
    <xsl:variable name="CONTAINS_PARAS" as="xs:string" select="'CONTAINS_PARAS'"/>




    <!-- JSON-DATA functions -->
    <!-- ebb: An accumulator function suggested on the XML Slack for numbering, in case we want it. Not sure we need it? -->
    <xsl:function name="nf:mapToArray" as="array(*)*">
        <xsl:param name="sourceMap" as="map(*)"/>
        <xsl:sequence select="
                fold-left(1 to map:size($sourceMap), [], function ($acc as array(*), $index as xs:integer)
                {
                    array:append($acc, $sourceMap($index))
                })"/>

    </xsl:function>
    <xsl:function name="nf:chapterMapper" as="map(*)*">
        <xsl:param name="part" as="element()+"/>
        <xsl:for-each select="$part">
            <xsl:map>
                <xsl:map-entry key="$PART">
                    <xsl:sequence select="current() ! name() ! normalize-space()"/>
                </xsl:map-entry>
                <xsl:variable name="chapterMaps" as="map(*)*">
                    <xsl:for-each
                        select="current()/div[not(@xml:id = 'DEPRECATIONS') and not(starts-with(@xml:id, 'REF-'))]">
                        <xsl:variable name="chap" as="element(div)" select="current()"/>
                        <xsl:map>
                            <xsl:map-entry key="$CHAPTER">
                                <xsl:value-of select="$chap/head ! normalize-space()"/>
                            </xsl:map-entry>
                            <xsl:map-entry key="$ID">
                                <xsl:value-of select="$chap/@xml:id ! normalize-space()"/>
                            </xsl:map-entry>
                            <xsl:map-entry key="'SEQUENCE'">
                                <xsl:value-of select="count($chap/preceding-sibling::*) + 1"/>
                            </xsl:map-entry>
                          <!-- <xsl:if test="current()[p]">
                                        <xsl:map-entry key="$CONTAINS_PARAS"><xsl:sequence select="array{nf:paraPuller(current()/p) }"/></xsl:map-entry>
                                    </xsl:if>-->
                        </xsl:map>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:map-entry key="$CONTAINS_CHAPTERS">
                    <xsl:sequence select="array {$chapterMaps}"/>
                </xsl:map-entry>
            </xsl:map>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="nf:DivPuller" as="map(*)*">
        <xsl:param name="div" as="element()"/>
        <xsl:param name="sectionLevel" as="xs:string"/>
        <xsl:map>
            <xsl:map-entry key="$NAME">
                <xsl:value-of select="$div/head ! normalize-space()"/>
            </xsl:map-entry>
            <xsl:map-entry key="$ID">
                <xsl:value-of select="$div/@xml:id ! normalize-space()"/>
            </xsl:map-entry>
            <xsl:map-entry key="'SEQUENCE'">
                <xsl:value-of select="count($div/preceding-sibling::div + 1)"/>
            </xsl:map-entry>

            <!-- Are you a section with nested subsections? If so, continue processing those subsections. -->
            <xsl:if test="$div/div[head]">
                <xsl:map-entry key="'CONTAINS-' || $sectionLevel || 'S'">

                    <xsl:sequence select="
                            array {
                                for $subd in $div/div[head]
                                return
                                    nf:DivPuller($subd, 'SECTION')
                            }"/>
                </xsl:map-entry>
            </xsl:if>

        </xsl:map>
    </xsl:function>
    <xsl:template match="/">
        <xsl:result-document href="../digitai-RAG-data.json" method="json" indent="yes">
            <xsl:map>
                <xsl:map-entry key="$DOCUMENT_TITLE">THE TEI GUIDELINES AS BASIS FOR A KNOWLEDGE
                    GRAPH</xsl:map-entry>
                <xsl:map-entry key="$PREPARED_BY">Digit-AI team: Elisa Beshero-Bondar, Hadleigh Jae
                    Bills, and Alexander Charles Fisher</xsl:map-entry>
                <xsl:map-entry key="$SUPPORTING_INSTITUTION">Penn State Erie, The Behrend
                    College</xsl:map-entry>
                <xsl:map-entry key="$TEI_SOURCE_VERSION_NUMBER">
                    <xsl:value-of select="$P5-version"/>
                </xsl:map-entry>
                <xsl:map-entry key="$TEI_SOURCE_OUTPUT_DATE">
                    <xsl:value-of select="$P5-versionDate"/>
                </xsl:map-entry>
                <xsl:map-entry key="$THIS_JSON_DATETIME">
                    <xsl:value-of select="$currentDateTime"/>
                </xsl:map-entry>
                <xsl:map-entry key="$CONTAINS_PARTS">
                    <xsl:sequence select="array {nf:chapterMapper($P5/TEI/text/*[not(self::back)])}"
                    />
                </xsl:map-entry>

            </xsl:map>
        </xsl:result-document>
        <xsl:apply-templates select="/" mode="cypher"/>
    </xsl:template>
    
    <!-- CYPHER MAP, FUNCTIONS AND TEMPLATES FOR IMPORTING THE JSON AND BUILDING THE GRAPH -->
    
    <!-- FUNCTION TO CREATE GRAPH NODES -->
    <xsl:function name="nf:generate-node-statement" as="xs:string">
        <xsl:param name="current-entity-type" as="xs:string"/>
        <xsl:param name="cypher-var" as="xs:string"/> 
        <xsl:param name="current-json-var" as="xs:string"/>
        
        
        <xsl:variable name="model" select="$nf:graph-model($current-entity-type)"/>
        <xsl:variable name="label" select="$model('label')"/>
        <!--  <xsl:variable name="cypher-var" as="xs:string" select="$model('cypherVar') ! string()"/>-->
        
        
        <xsl:variable name="node-clause" as="xs:string">
            <xsl:choose>
                <xsl:when test="map:contains($model, 'primaryKey')">
                    <xsl:variable name="current-cypher-pk" as="xs:string" select="$model('primaryKey') ! string()"/>
                    <xsl:sequence select="
                        'MERGE (' || $cypher-var|| ':' || $label ||
                        ' {' || $current-cypher-pk || ': ' ||$current-json-var||'.' || $model('jsonKeyForPK') || '})'
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
                    <!-- <xsl:sequence
                        select="$cypher-var||'.' || $prop-key || ' = ' || $current-json-var || '.' || $json-key"
                    />-->
                    <xsl:choose>
                        <xsl:when test="$json-key instance of map(*) and $json-key?isListComprehension">
                            <xsl:sequence select="
                                $cypher-var||'.'||$prop-key||' = [x IN '||$current-json-var||'.'||$json-key('sourceArrayPath')||' WHERE x IS NOT NULL | x.'||$json-key('sourcePropertyKey')||']'
                                "/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="
                                $cypher-var||'.'||$prop-key||' = '||$current-json-var||'.'||$json-key
                                "/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
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
    <!--  <xsl:function name="my:generate-foreach-statement" as="xs:string">
        <xsl:param name="child-type" as="xs:string"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="json-children-key" as="xs:string"/><!-\- ebb: for example: "CONTAINS_PARTS"  -\->
        <xsl:value-of select="$nltab||'FOREACH ('||$child-type||'_data'||' IN '||$parent-cypher-var||'_data.'||$json-children-key||' |'||$nltab"/>
    </xsl:function>
-->
    
    <!-- FUNCTION TO ESTABLISH EACH GRAPH EDGES (RELATIONSHIP CONNECTIONS)-->
    <xsl:function name="nf:generate-relationship-merge" as="xs:string+">
        <xsl:param name="child-cypher-var" as="xs:string"/>
        <xsl:param name="parent-cypher-var" as="xs:string"/>
        <xsl:param name="relationship-name" as="xs:string"/>
        
        
        <xsl:sequence select="
            'MERGE (' || $parent-cypher-var || ')-[:' || $relationship-name || ']->(' || $child-cypher-var || ')'
            "/>
    </xsl:function>
    
    <!-- FUNCTION FOR PROCESSING SEQUENCES OF SIBLINGS  -->
    <xsl:function name="nf:create-next-links" as="xs:string*">
        <xsl:param name="parent-label" as="xs:string"/>
        <xsl:param name="child-label" as="xs:string"/>
        <xsl:param name="relationship" as="xs:string"/>
        <xsl:param name="sort-property" as="xs:string"/>
        
        <xsl:variable name="cypher" as="xs:string" select="
            'MATCH (parent:'||$parent-label||')-[:'||$relationship||']->(child:'||$child-label||')
            WHERE child.'||$sort-property||' IS NOT NULL
            WITH parent, child ORDER BY child.'||$sort-property||'
            WITH parent, collect(child) AS ordered_children
            UNWIND range(0, size(ordered_children) - 2) AS i
            WITH ordered_children[i] AS n1, ordered_children[i+1] AS n2
            MERGE (n1)-[:NEXT]->(n2)'
            "/>
        <xsl:sequence select="$newline, '// Link sequential :', $child-label, ' nodes within each :', $parent-label, $newline, $cypher"/>
    </xsl:function>
    
    
    
    <!-- GENERATE CYPHER FROM THE SOURCE XML AND OUR GRAPH MODEL VARIABLE AT THE TOP OF THIS FILE -->
    
    
    <xsl:template match="/" mode="cypher">
        <xsl:variable name="currentXMLNode" as="document-node()" select="current()"/>
        <xsl:result-document href="../digitai-RAG-cypher.cypher" method="text">
            
            <!-- ebb: Define the variables in the graph model where the cypher script processing must begin. 
            Presumably it's the document mode, so that is what we've set here.-->
            <xsl:variable name="root-entity-type"  as="xs:string" select="'document'"/>
            <xsl:variable name="root-model" select="$nf:graph-model($root-entity-type)"/>
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
CALL apoc.load.json("https://raw.githubusercontent.com/newtfire/digitai/refs/heads/ebb-json/RAG/sandbox/sandboxTest.json") YIELD value as doc_data

// Create the root Document node
MERGE (doc:Document {title: 'SOURCE XML AS BASIS FOR A KNOWLEDGE GRAPH'})

</xsl:text>
            
            <xsl:call-template name="nf:process-children">
                <xsl:with-param name="parent_cypher_var" select="$root-model('cypherVar')"/>
                <xsl:with-param name="parent_json_var" select="'doc_data'"/>
                <xsl:with-param name="children_to_process" select="$root-model?children?*"/>
                <xsl:with-param name="indent" select="''"/>
                <xsl:with-param name="depth" select="1"/>
            </xsl:call-template>      
            
            <xsl:text>
;

// STEP 2: Create sequential :NEXT relationships
</xsl:text>
            
            <!--    <xsl:sequence select="my:create-next-links('part', 'sequence'), ';'"/>
            <xsl:sequence select="my:create-next-links('section', 'sequence'), ';'"/>-->
            
            <xsl:for-each select="map:keys($nf:graph-model)[exists($nf:graph-model(.)?children?*[?isSequence = true()])]">
                
                <xsl:variable name="parent-model" select="$nf:graph-model(.)"/>
                
                <xsl:for-each select="$parent-model?children?*[?isSequence = true()]">
                    <xsl:variable name="child-info" select="."/>
                    <xsl:variable name="child-model" select="$nf:graph-model($child-info?childEntityType)"/>
                    <xsl:sequence select="nf:create-next-links(
                        $parent-model('label'),
                        $child-model('label'),
                        $child-info('relationship'),
                        'sequence'
                        ), ';'"/>
                </xsl:for-each>
                
            </xsl:for-each>
            
            
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template name="nf:process-children">
        <xsl:param name="parent_cypher_var" as="xs:string"/>
        <xsl:param name="parent_json_var" as="xs:string"/>
        <xsl:param name="children_to_process" as="map(*)*"/>
        <xsl:param name="indent" as="xs:string"/>
        <xsl:param name="depth" as="xs:integer"/>
        
        <xsl:for-each select="$children_to_process">
            <xsl:variable name="child-info" select="."/>
            
            <xsl:variable name="child-type" select="$child-info('childEntityType')"/>
            <xsl:variable name="child-model" as="map(*)*" select="$nf:graph-model($child-type)"/>
            
          <xsl:if test="$child-type != 'specgrp'">
                <xsl:variable name="child-cypher-var" select="$child-model('cypherVar')"/>
             
       
                <xsl:variable name="child-json-var" select="$child-cypher-var||'_data_'||$depth"/>
                <xsl:variable name="relationship" select="$child-info('relationship')"/>
                <xsl:variable name="json-key" select="$child-info('jsonChildrenKey')"/>
                
                <xsl:sequence select="$newline||$indent||'WITH '||$parent_cypher_var||', '||$parent_json_var"/>
                <xsl:sequence select="$newline||$indent||'FOREACH ('||$child-json-var||' IN '||$parent_json_var||'.'||$json-key||' |'"/>
                <xsl:sequence select="$newline||$indent||$tab||nf:generate-node-statement($child-type, $child-cypher-var, $child-json-var)"/>
                <xsl:sequence select="$newline||$indent||$tab||'MERGE ('||$parent_cypher_var||')-[:'||$relationship||']->('||$child-cypher-var||')'"/>
                
                <xsl:if test="exists($child-model?children)">
                    <xsl:call-template name="nf:process-children">
                        <xsl:with-param name="parent_cypher_var" select="$child-cypher-var"/>
                        <xsl:with-param name="parent_json_var" select="$child-json-var"/>
                        <xsl:with-param name="children_to_process" select="$child-model?children?*"/>
                        <xsl:with-param name="indent" select="concat($indent, $tab)"/>
                        <xsl:with-param name="depth" select="$depth + 1"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:sequence select="$newline, $indent, ')'"/>
            </xsl:if>
      <xsl:if test="$child-type = 'specgrp'"> 
                <xsl:variable name="specgrp_model" select="$nf:graph-model('specgrp')"/>
                <xsl:variable name="specgrp_cypher_var" select="$specgrp_model('cypherVar')||'_'||$depth"/>
                <xsl:variable name="specgrp_json_var" select="$specgrp_model('cypherVar')||'_data_'||$depth"/>
                
                <xsl:variable name="spec_model" select="$nf:graph-model('spec')"/>
                <xsl:variable name="spec_cypher_var" select="$spec_model('cypherVar')"/>
                <xsl:variable name="spec_json_var" select="$spec_model('cypherVar')||'_item_'||$depth"/>
                
                <xsl:variable name="cypher-block">
                    <xsl:sequence select="$newline||$indent||'FOREACH ('||$specgrp_json_var||' IN '||$parent_json_var||'.CONTAINS_SPECGRPS |'"/>
                    <xsl:sequence select="$newline||$indent||$tab||'CREATE ('||$specgrp_cypher_var||':'||$specgrp_model('label')||')'"/>
                    <xsl:sequence select="$newline||$indent||$tab||'MERGE ('||$parent_cypher_var||')-[:HAS_SPECGRP]->('||$specgrp_cypher_var||')'"/>
                    <xsl:sequence select="$newline||$indent||$tab||'FOREACH ('||$spec_json_var||' IN '||$specgrp_json_var||'.SPECGRP |'"/>
                    <xsl:sequence select="$newline||$indent||$tab||$tab||'MERGE ('||$spec_cypher_var||':'||$spec_model('label')||' {name: '||$spec_json_var||'.SPEC})'"/>
                    <xsl:sequence select="$newline||$indent||$tab||$tab||'MERGE ('||$specgrp_cypher_var||')-[:HAS_SPEC]->('||$spec_cypher_var||')'"/>
                    
                    <xsl:if test="exists($spec_model?children)">
                        <xsl:call-template name="nf:process-children">
                            <xsl:with-param name="parent_cypher_var" select="$spec_cypher_var"/>
                            <xsl:with-param name="parent_json_var" select="$spec_json_var"/>
                            <xsl:with-param name="children_to_process" select="$spec_model?children?*"/>
                            <xsl:with-param name="indent" select="concat($indent, $tab, $tab)"/>
                            <xsl:with-param name="depth" select="$depth + 1"/>
                        </xsl:call-template>
                    </xsl:if>
                    
                    <xsl:sequence select="$newline, $indent, $tab, ')'"/>
                    <xsl:sequence select="$newline, $indent, ')'"/>
                </xsl:variable>
                <xsl:sequence select="$cypher-block"/>
                
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>

</xsl:stylesheet>
