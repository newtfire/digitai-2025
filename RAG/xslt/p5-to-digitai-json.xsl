<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg ="http://www.tei-c.org/ns/Examples"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:nf="http://newtfire.org"
    exclude-result-prefixes="xs math eg"
    version="3.0">
    
    <xsl:output method="json" indent="yes"/>
    
    <xsl:variable name="currentDateTime" as="xs:string" select="current-dateTime() ! string()"/>
    <xsl:variable name="P5" as="document-node()" select="doc('../p5.xml')"/>
    <xsl:variable name="P5-version" as="xs:string" select="$P5//edition/ref[2] ! normalize-space()"/>
    <xsl:variable name="P5-versionDate" as="xs:string" select="$P5//edition/date/@when ! normalize-space()"/>
    
    <!-- MODULE AND SPEC PULLING FUNCTIONS AND TEMPLATES -->
    
    <xsl:function name="nf:spcGrpPuller" as="array(*)*">
        <xsl:param name="spcGrps" as="element(specGrp)*"/>
       <xsl:variable name="specGrpMaps" as="map(*)*">
           <xsl:for-each select="$spcGrps">
               <xsl:variable name="specGrpRefs" as="xs:string*" select="current()/specGrpRef/@target ! normalize-space()"/>     
               <xsl:variable name="specs" as="element()*" select="current()/*[name() ! ends-with(., 'Spec')]"/>
               <xsl:sequence select="map {
                  'SPECGRP_ID' : current()/@xml:id ! normalize-space(),
                  'SPECGRP_NAME' : current()/@n ! normalize-space(),
                  'RELATES_TO' : array { nf:linkPuller($specGrpRefs)},
                  'CONTAINS_SPECS': array {nf:specPuller($specs)}
                   }"/>
           </xsl:for-each>
       </xsl:variable> 
        <xsl:sequence select="array{ $specGrpMaps
            }"/>
    </xsl:function>
    
    <xsl:function name="nf:specPuller" as="map(*)*">
        <xsl:param name="specs" as="element()*"/>
        <xsl:for-each select="$specs[not(self::paramSpec)]">
            <xsl:variable name="glosses" as="element()*" select="current()/gloss"/>
            <xsl:variable name="descs" as="element()*" select="current()/desc"/>
            <xsl:variable name="remarks" as="element()*" select="current()/remarks"/>
            <xsl:variable name="constraints" as="element()*" select="current()/constraintSpec[not(descendant::sch:pattern)]"/>
            <xsl:variable name="exempla" as="element()*" select="current()/exemplum"/>
            <xsl:variable name="contentModel" as="map(*)*">
                <xsl:if test="current()/content">
                    <xsl:call-template name="content">
                    <xsl:with-param name="content" as="element(content)" select="current()/content"/>
                </xsl:call-template></xsl:if>
            </xsl:variable>
            <xsl:sequence select="map{
                'SPEC_TYPE' : current()/name(),
                'SPEC_NAME': current()/@ident ! normalize-space(),
                'PART_OF_MODULE': current()/@module ! normalize-space(), 
                'MEMBER_OF_CLASS' : array {current()/classes/memberOf/@key ! normalize-space()},
                'EQUIVALENT_NAME' : current()/equiv ! normalize-space(),
                'GLOSSED_BY': array { nf:glossDescPuller($glosses)},
                'DESCRIBED_BY': array{ nf:glossDescPuller($descs)},
                'CONTENT_MODEL' : array { $contentModel },
                'LISTS_ATTRIBUTES' : array { nf:attListPuller(current()/attList) },
                'CONSTRAINED_BY': array {nf:constraintPuller($constraints)},
                'CONTAINS_EXAMPLES': array{ nf:exemplumPuller($exempla)},
                'REMARKS_ON': array { nf:glossDescPuller($remarks) }
                }"/>   
        </xsl:for-each>         
    </xsl:function>
    
    <xsl:function name="nf:attListPuller" as="map(*)*">
        <xsl:param name="attList" as="element(attList)*" />

        <xsl:variable name="attDefs" as="element(attDef)*" select="$attList/attDef"/>
       <xsl:variable name="attDefMaps" as="map(*)*">
           <xsl:for-each select="$attDefs">
           <xsl:variable name="glosses" as="element()*" select="current()/gloss"/>
           <xsl:variable name="descs" as="element()*" select="current()/desc"/>
           <xsl:variable name="remarks" as="element()*" select="current()/remark"/>
           <xsl:variable name="defaultVal" as="xs:string?" select="current()/defaultVal ! normalize-space()"/>
           <xsl:variable name="constraints" as="element()*" select="current()/constraintSpec[not(descendant::sch:pattern)]"/>
          <xsl:variable name="exempla" as="element()*" select="current()/exemplum"/>
           <xsl:variable name="datatype" as="map(*)*"> 
              <xsl:if test="current()/datatype">
                 <xsl:variable name="valDescs" as="array(*)*">
                     <xsl:if test="current()/valDesc">
                           <xsl:variable name="valDescInfo" as="map(*)*">
                               <xsl:for-each select="current()/valDesc">
                                   <xsl:sequence select="map{
                                       'LANGUAGE' : (current()/@xml:lang ! normalize-space(), 'en')[1],
                                       'VALDESC' : current() ! normalize-space()
                                       }"/>
                               </xsl:for-each>
                           </xsl:variable>
                           <xsl:sequence select="array{ $valDescInfo}"/>
                     </xsl:if>
                       </xsl:variable>
               
                   <xsl:sequence select="map {
                       'DATATYPE': current()/datatype/dataRef/@key ! normalize-space(),
                       'DATATYPE_DESCRIBED_BY': $valDescs
                       }"/> 
               </xsl:if>               
        </xsl:variable>
          <xsl:sequence select="map{
              'ATTRIBUTE_DEFINITION' : current()/@ident ! normalize-space(),
              'USAGE': current()/@usage ! normalize-space(),
              'GLOSSED_BY': array { nf:glossDescPuller($glosses) },
              'DESCRIBED_BY': array { nf:glossDescPuller($descs)},
               'TAKES_DEFAULT_VALUE': $defaultVal,
               'TAKES_DATATYPE': array {$datatype},
               'CONSTRAINED_BY': array {nf:constraintPuller($constraints)},
               'CONTAINS_EXAMPLES': array{ nf:exemplumPuller($exempla)},
               'REMARKS_ON': array{ nf:glossDescPuller($remarks)},
               'CONTAINS_VALUE_LIST': array { nf:valListPuller(current()/valList) }
              }"/>
       </xsl:for-each> 
       </xsl:variable>
        <xsl:choose>
           <xsl:when test="$attList/attList">
               <xsl:sequence select="map{
               'DEFINES_ATTRIBUTES' : array{ $attDefMaps},
               'LISTS_ATTRIBUTES' : array { nf:attListPuller($attList/attList) }   
               }"/>
           </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="map{
                    'DEFINES_ATTRIBUTES' : array{ $attDefMaps}
                    }"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="nf:valListPuller" as="map(*)*">
        <xsl:param name="valList" as="element()*"/>
        <xsl:variable name="valItems" as="element()*"/>
        <xsl:variable name="valItemsUnpacked" as="map(*)*">
            <xsl:for-each select="$valItems">
                <xsl:variable name="descs" as="element()*" select="current()/desc"/>
                <xsl:variable name="glosses" as="element()*" select="current()/gloss"/>
                <xsl:variable name="paramList" as="element()*" select="current()/paramList"/>
                <xsl:sequence select="map{
                    'VALUE' : current()/@ident ! normalize-space(),
                    'EQUIVALENT_NAME' : current()/equiv ! normalize-space(),
                    'GLOSSED_BY' : array {nf:glossDescPuller($glosses) },
                    'DESCRIBED_BY': array {nf:glossDescPuller($descs) },
                    'HAS_PARAM_LIST': array {nf:paramListPuller($paramList)}
                    }"/>                                
            </xsl:for-each>
        </xsl:variable>        
        <xsl:sequence select="map{ 
            'VAL_LIST_TYPE': $valList/@type ! normalize-space(),
            'VALUE_OPTIONS': array{ }
            }"/>
    </xsl:function>
    <xsl:function name="nf:paramListPuller" as="map(*)*">
        <xsl:param name="paramList" as="element()*"/>
          <xsl:variable name="paramSpecs" as="element()*" select="$paramList/paramSpec"/>
        <xsl:for-each select="$paramSpecs">
            <xsl:variable name="paramDescs" as="element()*" select="current()/desc"/>
            <xsl:sequence select="map{
                'PARAMETER' : current()/@ident ! normalize-space(),
                'DESCRIBED_BY' : array{nf:glossDescPuller($paramDescs) }
                }"/>
        </xsl:for-each>        
    </xsl:function>
    <xsl:function name="nf:constraintPuller" as="map(*)*">
        <xsl:param name="constraintSpecs" as="element(constraintSpec)*"/>
        <xsl:for-each select="$constraintSpecs">
            <xsl:variable name="rules" as="element()*" select="current()//sch:rule"/>
            <xsl:variable name="constraint" as="map(*)*">
                <xsl:for-each select="$rules">
                <xsl:variable name="tests" as="map(*)*">
                    <xsl:for-each select="current()/(sch:let, sch:assert, sch:report)">
                       <xsl:choose>
                           <xsl:when test="current()/local-name() ='let'">
                               <xsl:sequence select="map{ 
                                   'VARIABLE_FOR_TEST' : map{ 
                                       'VARIABLE_NAME' : current()/@name ! normalize-space(),
                                       'VARIABLE_VALUE': current()/@value ! normalize-space()
                                   }}"/>
                           </xsl:when>
                           <xsl:when test="current() ! local-name() = 'assert'">
                               <xsl:sequence select="map{ 
                           'ASSERT_MUST_BE_TRUE' : current()/@test ! string(),
                           'TEST' : normalize-space(.)
                           }"/></xsl:when>
                           <xsl:otherwise>
                             <xsl:sequence select="map{ 
                            'REPORT_MUST_BE_FALSE' : current()/@test ! string(),
                             'TEST' : normalize-space(.)
                                   }"/>
                               
                           </xsl:otherwise>
     
                       </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:sequence select="map{
                    'CONTEXT' : current()/@context ! string(),
                    'TESTED_BY': array{$tests}
                    }"/>
            </xsl:for-each></xsl:variable>
            <xsl:sequence select="map{ 
                'ID' : current()/@ident ! normalize-space(),
                'DESCRIBED_BY': array{nf:glossDescPuller(current()/desc) },
                'RULES' : array{ $constraint }
                }"/>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="nf:exemplumPuller" as="map(*)*">
        <xsl:param name="exempla" as="element()*"/>
        <xsl:for-each select="$exempla">
            <xsl:variable name="paras" select="current()/child::*[local-name() = 'p']"/>
           <xsl:variable name="egXMLs" as="array(*)*">
                    <xsl:if test="current()/eg:egXML">
                        <xsl:sequence select="array {current()//eg:egXML}"/>
                    </xsl:if> 
                </xsl:variable> 
            <xsl:sequence select="map{
                'LANGUAGE' : (current()/@xml:lang ! normalize-space(), 'en')[1],
                'CONTAINS_PARAS' :  array {nf:paraPuller($paras)},
                'EXAMPLE': $egXMLs
            }"/>
        </xsl:for-each>
        
    </xsl:function>
    
    <xsl:function name="nf:attUnpacker" as="map(*)*">
        <!-- ebb: This is for attribute nodes to unpack names and values. -->
        <xsl:param name="atts" as="attribute()*"/>
         <xsl:for-each select="$atts">
             <xsl:sequence select="map{
                  current()/name() : current() ! normalize-space()
                 }"/>
         </xsl:for-each>
    </xsl:function>
    
     <xsl:template name="content">
         <xsl:param name="content" as="element()"/>
       
        <xsl:variable name="contentIndicators" as="map(*)*" select="nf:attUnpacker($content/*/@*)"/>
        <xsl:variable name="contentModelParts" as="map(*)*">
            <xsl:for-each select="$content/*/*">
                <xsl:variable name="cmpAtts" as="map(*)*" select="nf:attUnpacker(current()/@*)"/>      
                <xsl:sequence select="map{ 
                    current()/name() : array {$cmpAtts}
                    }"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="map{
            $content/* ! name() : array {$contentIndicators},
            'CONTAINS' : array {$contentModelParts}  
              
            } "/>
    </xsl:template>
    
    <xsl:function name="nf:glossDescPuller" as="map(*)*">
        <xsl:param name="glossies" as="element()*"/>
        <xsl:for-each select="$glossies">
            <xsl:variable name="remarkInnards" as="array(*)*">
                <xsl:choose>
                    <xsl:when test="current()[not(p)]">
                        <xsl:sequence select="array{ current() ! normalize-space()}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="paras" as="element()+" select="current()//p"/>
                        <xsl:sequence select="array{nf:paraPuller($paras)}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
                    <xsl:sequence select="map{
            current() ! upper-case(name()) : $remarkInnards,
            'LANGUAGE' : current()/@xml:lang ! normalize-space(),
            'VERSION_DATE': current()/@versionDate ! xs:date(.)
                }"/>
        </xsl:for-each>      
    </xsl:function>
    
    <!-- COLLECTION OF TEMPLATES THAT PROCESS PARAGRAPH_LEVEL CHUNKS --> 
    <xsl:template match="ptr">
        <xsl:variable name="targetMatch" as="xs:string" select="substring-after(@target, '#')"/>
        <xsl:value-of select="@target ! normalize-space()"/>
        <xsl:value-of select="' ('||$P5//div[@xml:id = $targetMatch]/head ! normalize-space()||') '"/>
    </xsl:template>
    
    <!-- ebb: function just to normalize-space() and take distinct-values() from an XML node. -->
    <xsl:function name="nf:ndv" as="xs:string+">
        <xsl:param name="node" as="node()+"/>
            <xsl:sequence select="$node ! normalize-space() => distinct-values()"/>
    </xsl:function>
    
    <xsl:function name="nf:linkPuller" as="array(*)*">
        <xsl:param name="targets"/>
        <xsl:variable name="targetMatch" as="xs:string*" select="for $t in $targets return substring-after($t, '#')"/>
        <xsl:sequence select="array {
            for $t in $targetMatch return 
            map {
            'ID': $t
            }
            }"/>
        
    </xsl:function>
    <xsl:function name="nf:paraPuller" as="map(*)*">
        <xsl:param name="paras" as="element()*"/>
        <xsl:for-each select="$paras">
            <xsl:variable name="currentSourcePara" as="element()" select="current()"/>
            <xsl:variable name="paraProcessed" as="element()*">
                <p><xsl:apply-templates/></p>
            </xsl:variable>
            <xsl:variable name="paraString" as="xs:string*">
                <xsl:sequence select="$paraProcessed ! normalize-space()"/>
            </xsl:variable>
            <xsl:variable name="sequence" as="xs:integer">
                <xsl:value-of select="count(current()/preceding-sibling::p) + 1"/>
            </xsl:variable>
            
            <xsl:variable name="moreThanText" as="array(*)*">
                <xsl:if test="current()//*[local-name() = ( 'moduleSpec', 'gi', 'att', 'ident', 'egXML', 'specGrp')]">
                    <xsl:variable name="moduleSpec" as="map(*)*">
                        <xsl:if test="current()//moduleSpec">
                            <xsl:sequence select="map{
                                'MODULE' : current()//moduleSpec/idno ! normalize-space(),
                                'DESCRIBED_BY': array{ nf:glossDescPuller(current()/moduleSpec/desc)}
                                }"/>
                        </xsl:if>
                        
                    </xsl:variable>
                    
                    <xsl:variable name="elementsMentioned" as="map(*)*">
                        <xsl:if test="current()//gi"> 
                            <xsl:sequence select="map {'ELEMENTS_MENTIONED': array {current()//gi => nf:ndv()}}"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="attsMentioned" as="map(*)*">
                        <xsl:if test="current()//att">
                            <xsl:sequence select="map {'ATTRIBUTES_MENTIONED': array {current()//att => nf:ndv()}}"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="identsMentioned" as="map(*)*">
                        <xsl:for-each select="current()//ident/@type => distinct-values()">
                            <xsl:sequence select="map { 
                                upper-case(current()) : array {$currentSourcePara//ident[@type=current()] => nf:ndv()}}"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="exempla" as="map(*)*">
                       <xsl:if test="current()//eg:egXML">
                       <xsl:sequence select="map {'EXAMPLES': array {current()//eg:egXML}}"/>
                       </xsl:if> 
                    </xsl:variable> 
                    <xsl:variable name="specGrps" as="map(*)*">
                        <xsl:if test ="current()/specGrp">
                            <xsl:sequence select="map{'CONTAINS_SPECGRPS' : nf:spcGrpPuller(current()/specGrp)}"/>
                        </xsl:if>
                    </xsl:variable>
                    
                    <xsl:sequence select="array{$moduleSpec, $elementsMentioned, $attsMentioned, $identsMentioned, $exempla, $specGrps }"/>
                </xsl:if>    
            </xsl:variable>
           
            <xsl:sequence select="map { 
                'PARA': $paraString,
                'SEQUENCE': $sequence,
                'TEI_ENCODING_DISCUSSED' : $moreThanText
                }"/>
   
        </xsl:for-each>
    </xsl:function>
   
    <xsl:function name="nf:chapterMapper" as="map(*)*">
        <xsl:param name="part" as="element()+"/>
        <xsl:for-each select="$part">
            <xsl:map>
                <xsl:map-entry key="'PART'"><xsl:sequence select="current() ! name() ! normalize-space()"/></xsl:map-entry>
                <xsl:map-entry key="'SEQUENCE'"><xsl:value-of select="current()/preceding-sibling::* => count() + 1"/></xsl:map-entry>
                <xsl:variable name="chapterMaps" as="map(*)*"> 
                    <xsl:for-each select="current()/div[not(@xml:id='DEPRECATIONS') and not(starts-with(@xml:id, 'REF-'))]">
                        <xsl:variable name="chap" as="element(div)" select="current()"/>
                        <xsl:variable name="targets" as="item()*" select="child::p//*[self::ptr or self::ref or self::specGrpRef]
                            [not(@target ! substring-after(., '#') = //back//*/@xml:id)]/@target ! normalize-space()"/>
                        <xsl:map>
                            <xsl:map-entry key="'CHAPTER'"><xsl:value-of select="$chap/head ! normalize-space()"/></xsl:map-entry>
                            <xsl:map-entry key="'ID'"><xsl:value-of select="$chap/@xml:id ! normalize-space()"/></xsl:map-entry>
                            <xsl:map-entry key="'SEQUENCE'">
                                <xsl:value-of select="count($chap/preceding-sibling::*) + 1"/>
                            </xsl:map-entry>
                             <xsl:if test="current()[p]">
                                        <xsl:map-entry key="'CONTAINS_PARAS'"><xsl:sequence select="array{nf:paraPuller(current()/p) }"/></xsl:map-entry>
                                    </xsl:if>
                            <xsl:if test="current()[specGrp]">
                                <xsl:map-entry key="'CONTAINS_SPECGRPS'"><xsl:sequence select="nf:spcGrpPuller(current()/specGrp)"/></xsl:map-entry>
                            </xsl:if>
                            <xsl:if test="current()/child::*[name() ! ends-with(., 'Spec')]">
                                <xsl:map-entry key="'CONTAINS_SPECS'"><xsl:sequence 
                                        select="array{nf:specPuller(current()/child::*[name() ! ends-with(., 'Spec')])}"/>
                                </xsl:map-entry>
                            </xsl:if>
                            <xsl:if test="count($targets) gt 0">
                                <xsl:map-entry key="'RELATES_TO'"><xsl:sequence select="nf:linkPuller($targets)"/></xsl:map-entry>
                            </xsl:if>
                        </xsl:map>
                    </xsl:for-each>
                </xsl:variable> 
                <xsl:map-entry key="'CONTAINS_CHAPTERS'"><xsl:sequence select="array{ $chapterMaps}"/></xsl:map-entry>
            </xsl:map>
        </xsl:for-each>
    </xsl:function>
    <xsl:template match="/">
        <xsl:result-document href="../digitai-p5.json" method="json" indent="yes"> 
            <xsl:map>
                <xsl:map-entry key="'DOCUMENT_TITLE'">THE TEI GUIDELINES AS BASIS FOR A KNOWLEDGE GRAPH</xsl:map-entry> 
                <xsl:map-entry key="'PREPARED_BY'">Digit-AI team: Elisa Beshero-Bondar, Hadleigh Jae Bills, and Alexander Charles Fisher</xsl:map-entry>
                <xsl:map-entry key="'SUPPORTING_INSTITUTION'">Penn State Erie, The Behrend College</xsl:map-entry>
                <xsl:map-entry key="'TEI_SOURCE_VERSION_NUMBER'"><xsl:value-of select="$P5-version"/></xsl:map-entry>
                <xsl:map-entry key="'TEI_SOURCE_OUTPUT_DATE'"><xsl:value-of select="$P5-versionDate"/></xsl:map-entry>
                <xsl:map-entry key="'THIS_JSON_DATETIME'"><xsl:value-of select="$currentDateTime"/></xsl:map-entry>
                <xsl:map-entry key="'CONTAINS_PARTS'">
                    <xsl:sequence select="array { nf:chapterMapper($P5/TEI/text/*[not(self::back)])}"/>
                </xsl:map-entry>
                
            </xsl:map>
        </xsl:result-document>
    </xsl:template>
    
    
   
    
</xsl:stylesheet>