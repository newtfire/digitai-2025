<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg ="http://www.tei-c.org/ns/Examples"
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
        <xsl:param name="modules"/>
       <xsl:variable name="moduleMaps" as="map(*)*">
           <xsl:for-each select="$modules">
               <xsl:variable name="specGrpRefs" as="xs:string*" select="current()/specGrpRef/@target ! normalize-space()"/>     
               <xsl:variable name="specs" as="element()*" select="current()//*[name() ! ends-with(., 'Spec')]"/>
               <xsl:sequence select="map {
                  'SPECGRP-ID' : current()/@xml:id ! normalize-space(),
                  'SPECGRP-NAME' : current()/@n ! normalize-space(),
                  'RELATES-TO' : array { nf:linkPuller($specGrpRefs)},
                  'CONTAINS-SPECS': array {nf:specPuller($specs)}
          
                   }"/>
           </xsl:for-each>
       </xsl:variable> 
        <xsl:sequence select="array{ $moduleMaps
            }"/>
    </xsl:function>
    
    <xsl:function name="nf:specPuller" as="map(*)*">
        <xsl:param name="specs" as="element()*"/>
        <xsl:for-each select="$specs[not(self::paramSpec)]">
            <xsl:variable name="glosses" as="element()*" select="current()/gloss"/>
            <xsl:variable name="descs" as="element()*" select="current()/desc"/>
            <xsl:variable name="contentModel" as="map(*)*">
                <xsl:if test="current()/content"><xsl:call-template name="content">
                    <xsl:with-param name="content" as="element(content)" select="current()/content"/>
                </xsl:call-template></xsl:if>
            </xsl:variable>
            <xsl:sequence select="map{
                'SPEC-TYPE' : current()/name(),
                'PART-OF': current()/@module ! normalize-space(), 
                'SPEC-NAME': current()/@ident ! normalize-space(),
                'GLOSSED-BY': array { nf:glossDescPuller($glosses)},
                'DESCRIBED-BY': array{ nf:glossDescPuller($descs)},
                'CONTENT-MODEL' : array { $contentModel }
                }"/>
        </xsl:for-each>         
    </xsl:function>
    
    <xsl:function name="nf:attUnpacker" as="map(*)*">
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
        <xsl:param name="glosses-or-descs"/>
        <xsl:for-each select="$glosses-or-descs">
            <xsl:sequence select="map{
            current() ! upper-case(name()) : current() ! normalize-space(),
            'LANGUAGE' : current()/@xml:lang ! normalize-space(),
            'VERSION-DATE': current()/@versionDate ! xs:date(.)
                }"/>
        </xsl:for-each>      
    </xsl:function>
    
    <!-- COLLECTION OF TEMPLATES THAT PROCESS PARAGRAPH-LEVEL CHUNKS --> 
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
            
            <xsl:variable name="moreThanText" as="array(*)*">
                <xsl:if test="current()//*[local-name() = ( 'moduleSpec', 'gi', 'att', 'ident', 'egXML')]">
                    <xsl:variable name="moduleSpec" as="map(*)*">
                        <xsl:if test="current()//moduleSpec">
                            <xsl:sequence select="map{
                                'MODULE' : current()//moduleSpec/idno ! normalize-space(),
                                'DESCRIBED-BY': array{ nf:glossDescPuller(current()/moduleSpec/desc)}
                                }"/>
                        </xsl:if>
                        
                    </xsl:variable>
                    
                    <xsl:variable name="elementsMentioned" as="map(*)*">
                        <xsl:if test="current()//gi"> 
                            <xsl:sequence select="map {'ELEMENTS MENTIONED': array {current()//gi => nf:ndv()}}"/>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:variable name="attsMentioned" as="map(*)*">
                        <xsl:if test="current()//att">
                            <xsl:sequence select="map {'ATTRIBUTES MENTIONED': array {current()//att => nf:ndv()}}"/>
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
                    <xsl:sequence select="array{$moduleSpec, $elementsMentioned, $attsMentioned, $identsMentioned, $exempla }"/>
                </xsl:if>    
            </xsl:variable>
            <xsl:variable name="specGrps" as="element()*" select="child::specGrp"/>
            <xsl:sequence select="map { 
                'PARA': $paraString,
                'Para-String-Length': $paraString ! string-length(),
                'ENCODING-MENTIONS' : $moreThanText,
                'CONTAINS-SPECGRPS' : nf:spcGrpPuller($specGrps)
                }"/>
   
        </xsl:for-each>
    </xsl:function>
   
    <xsl:function name="nf:chapterDivPull" as="map(*)*">
        <xsl:param name="div" as="element()"/>
        <xsl:param name="whichDiv" as="xs:string?"/>
        <xsl:param name="sectionLevel" as="xs:string"/>

        <xsl:for-each select="$div/div[head]">
            <!-- Store my child <p> elements: -->
            <xsl:variable name="paras" as="element()*" select="child::p"/>
            <xsl:variable name="targets" as="item()*" select="child::p//ptr/@target ! normalize-space()"/>
            <xsl:variable name="specGrps" as="element()*" select="child::specGrp"/>
            <xsl:variable name="specs" as="element()*" select="current()/*[name() ! ends-with(., 'Spec')]"/>
         <!-- Are you a section with nested subsections? If so, continue processing those subsections. Otherwise, stop here. -->
           <xsl:choose> 
               <xsl:when test="current()[child::div[head]]">
                   <xsl:sequence select="map {
                       'SECTION-LEVEL-'||(current()/@type ! normalize-space(),'unmarked')[1] ! string() : current()/head ! normalize-space(),
                       'ID': current()/@xml:id ! normalize-space(),
                       'CONTAINS-'||$sectionLevel : array { nf:chapterDivPull(current(), (current()/@type ! normalize-space(), '')[1], 'NESTED-SUBSECTION') },
                       'CONTAINS-PARAS': array {nf:paraPuller($paras)},
                       'RELATES-TO': nf:linkPuller($targets),
                       'CONTAINS-CITATION' : 'Unpack BIB cites here',
                       'CONTAINS-SPECGRPS' : nf:spcGrpPuller($specGrps),
                       'CONTAINS-SPECS': array {nf:specPuller($specs)}
                       }"/> 
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="map {
                    'SECTION-LEVEL-'||(current()/@type ! normalize-space(),'unmarked')[1] : current()/head ! normalize-space(),
                    'ID' : current()/@xml:id ! normalize-space(),
                    'CONTAINS-PARAS': array {nf:paraPuller($paras)},
                    'RELATES-TO': nf:linkPuller($targets),
                    'CONTAINS-CITATION' : 'Unpack BIB cites here',
                    'CONTAINS-SPECGRPS' : nf:spcGrpPuller($specGrps),
                    'CONTAINS-SPECS': array {nf:specPuller($specs)}
                    }"/>
            </xsl:otherwise>
           </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="/">
        <xsl:result-document href="../digitai-p5.json" method="json" indent="yes"> 
         <xsl:variable name="partInfo" as="map(*)*"> 
           <xsl:for-each select="child::TEI[1]/text/*[not(name() = 'back')]">
            <xsl:variable name="chapterMaps" as="map(*)*">
                <xsl:apply-templates select="current()"/>
            </xsl:variable>
            <xsl:sequence select="map {
                'PART' : current()/name(),
                'CONTAINS-CHAPTERS': array { $chapterMaps
                }}"/>
        </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="map {
            'DOCUMENT-TITLE' : 'THE TEI GUIDELINES AS BASIS FOR A KNOWLEDGE GRAPH',
            'PREPARED-BY' : 'Digit-AI team: Elisa Beshero-Bondar, Hadleigh Jae Bills, and Alexander Charles Fisher',
            'SUPPORTING-INSTITUTION': 'Penn State Erie, The Behrend College',
            'TEI_SOURCE-VERSION-NUMBER': $P5-version,
            'TEI_SOURCE-OUTPUT-DATE' : $P5-versionDate,
            'THIS-JSON-DATETIME': $currentDateTime,
            'CONTAINS-PARTS' : array { $partInfo }
            }"/>
     </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="text/*" as="map(*)*">      
   <xsl:variable name="chapters" as="map(*)*">
       <!--ebb: NOTE: Here we are excluding the P5 Subset file's references to the REF- and Deprecations files we've removed.  -->
       <!-- 2025-06-18 ebb: JUST constraining this to output the AI (Analytic Mechanisms) chapter -->
       
       <xsl:for-each select="child::div[not(@xml:id='DEPRECATIONS') and not(starts-with(@xml:id, 'REF-'))]">
           <xsl:variable name="chap" select="current()" as="element()"/>
           <xsl:variable name="targets" as="item()*" select="$P5/div[@xml:id = current()/@xml:id]/child::p//ptr/@target ! normalize-space()"/>
           <xsl:variable name="specGrps" as="element()*" select="current()/specGrp"/>
           <xsl:variable name="specs" as="element()*" select="current()/*[name() ! ends-with(., 'Spec')]"/>

         <xsl:choose> 
             <xsl:when test="current()/p">
             <xsl:variable name="paras" as="element()*" select="$P5//div[@xml:id = current()/@xml:id]/child::p"/>
             
            <xsl:sequence select=" map {
               'CHAPTER': $chap/head ! normalize-space(),
               'ID': $chap/@xml:id ! string(),
               'CONTAINS-SECTIONS': array { nf:chapterDivPull($chap, 'div1', 'SUBSECTION') },
               'CONTAINS-PARAS': array {nf:paraPuller($paras)},
               'RELATES-TO': nf:linkPuller($targets),
               'CONTAINS-CITATION' : 'Unpack BIB cites here',
               'CONTAINS-MODULE' : nf:spcGrpPuller($specGrps),
               'CONTAINS-SPECS' : array {nf:specPuller($specs)}
               } 
               "/>
             </xsl:when>
             <xsl:otherwise>
                 
               <xsl:sequence select=" map {
                     'CHAPTER': $chap/head ! normalize-space(),
                     'ID': $chap/@xml:id ! string(),
                     'CONTAINS-SECTIONS': array { nf:chapterDivPull($chap, 'div1', 'SUBSECTION') },
                     'CONTAINS-SPECGRPS' : nf:spcGrpPuller($specGrps),
                     'CONTAINS-SPECS' : array {nf:specPuller($specs)}
                     } 
                     "/> 
             </xsl:otherwise>
         
         </xsl:choose>
       </xsl:for-each>
        </xsl:variable>
        
        <xsl:sequence select=" $chapters "/>
    </xsl:template>
    
   
  
    
</xsl:stylesheet>