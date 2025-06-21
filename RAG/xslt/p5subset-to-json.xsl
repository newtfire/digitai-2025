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
    <xsl:variable name="P5-subset-version" as="xs:string" select="//edition/ref[2] ! normalize-space()"/>
    <xsl:variable name="P5-subset-versionDate" as="xs:string" select="//edition/date/@when ! normalize-space()"/>
    
    <xsl:variable name="P5-chapters" as="document-node()+" select="collection('../p5-chapters/en-2025-06-17/?select=*.xml')"/>
     <!-- 2025-06-17 ebb: The directory path will change with updates to the P5 subset saved to the repo. We are removing the following:
     * BIBL (too much information indirectly related to the elements  
     * file named "DEPRECATION" (contains little explicit information)
     * files with names starting REF- (mostly empty files that represent from the element / attribute / class / module specs)
     -->
    
    <!-- COLLECTION OF TEMPLATES THAT PROCESS NUGGETS OF INFO IN PARAGRAPHS -->
    
   
    <xsl:template match="ptr">
        <xsl:variable name="targetMatch" as="xs:string" select="substring-after(@target, '#')"/>
        <xsl:value-of select="@target ! normalize-space()"/>
        <xsl:value-of select="' ('||$P5-chapters//div[@xml:id = $targetMatch]/head ! normalize-space()||') '"/>
    </xsl:template>
    
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
            <xsl:variable name="paraProcessed" as="element()*">
                <p><xsl:apply-templates/></p>
            </xsl:variable>
            <xsl:variable name="paraString" as="xs:string*">
                <xsl:sequence select="$paraProcessed ! normalize-space()"/>
            </xsl:variable>
            <xsl:variable name="elementsMentioned" as="array(*)*">
                <xsl:sequence select="array {current()//gi ! normalize-space()}"/>
            </xsl:variable>
            <xsl:variable name="attsMentioned" as="array(*)*">
                <xsl:sequence select="array {current()//att ! normalize-space()}"/>
            </xsl:variable>
            <xsl:variable name="attClasses" as="array(*)*">
                <xsl:sequence select="array {current()//ident[@type='class']}"/>
            </xsl:variable>
            <xsl:variable name="models" as="array(*)*">
                <xsl:sequence select="array {current()//ident[@type='model']}"/>
            </xsl:variable>
            <xsl:variable name="macros" as="array(*)*">
                <xsl:sequence select="array {current()//ident[@type='macro']}"/>
            </xsl:variable>
            <xsl:variable name="modules" as="array(*)*">
                <xsl:sequence select="array {current()//ident[@type='module']}"/>
            </xsl:variable>
            <xsl:variable name="namespaces" as="array(*)*">
                <xsl:sequence select="array {current()//ident[@type='ns']}"/>
            </xsl:variable>
            <xsl:variable name="exempla" as="array(*)*">
                <xsl:sequence select="array {current()//eg:egXML}"/>
            </xsl:variable>
            <xsl:sequence select="map { 
                'PARA': $paraString,
                'Para-String-Length': $paraString ! string-length(),
                'ELEMENTS MENTIONED':  $elementsMentioned ,
                'ATTRIBUTES MENTIONED': $attsMentioned ,
                'ATTRIBUTE CLASSES MENTIONED': $attClasses,
                'MODELS MENTIONED' : $models,
                'MACROS MENTIONED': $macros,
                'MODULES MENTIONED': $modules,
                'NAMESPACES MENTIONED': $namespaces,
                'EXAMPLES': $exempla
                }"/>
   
        </xsl:for-each>
    </xsl:function>
   
    <xsl:function name="nf:chapterDivPull" as="map(*)*">
        <xsl:param name="input-id" as="xs:string"/>
        <xsl:param name="whichDiv" as="xs:string"/>
        <xsl:param name="sectionLevel" as="xs:string"/>

        <xsl:for-each select="$P5-chapters//div[@type=$whichDiv and @xml:id =$input-id ]/div[@type and @xml:id]">
            <!-- Store my child <p> elements: -->
            <xsl:variable name="paras" as="element()*" select="child::p"/>
            <xsl:variable name="targets" as="item()*" select="child::p//ptr/@target ! normalize-space()"/>
         <!-- Are you a section with nested subsections? If so, continue processing those subsections. Otherwise, stop here. -->
           <xsl:choose> 
               <xsl:when test="current()[child::div/@type]">
                   <xsl:sequence select="map {
                       'SECTION' : current()/head ! normalize-space(),
                       'ID': current()/@xml:id ! string(),
                       'CONTAINS-'||$sectionLevel : array { nf:chapterDivPull(current()/@xml:id, current()/@type, 'NESTED-SUBSECTION') },
                       'CONTAINS-PARAS': array {nf:paraPuller($paras)},
                       'RELATES-TO': nf:linkPuller($targets),
                       'CONTAINS-CITATION' : 'Unpack BIB cites here',
                       'CONTAINS-SPECS' : 'nf:specPuller() coming here'
                       }"/> 
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="map {
                    'SECTION' : current()/head ! string(),
                    'ID' : current()/@xml:id ! string()
                    }"/>
            </xsl:otherwise>
           </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="/">
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
            'TEI_SOURCE-VERSION-NUMBER': $P5-subset-version,
            'TEI_SOURCE-OUTPUT-DATE' : $P5-subset-versionDate,
            'THIS-JSON-DATETIME': $currentDateTime,
            'CONTAINS-PARTS' : array { $partInfo }
            }"/>
    </xsl:template>
    
    <xsl:template match="text/*" as="map(*)*">      
   <xsl:variable name="chapters" as="map(*)*">
       <!--ebb: NOTE: Here we are excluding the P5 Subset file's references to the REF- and Deprecations files we've removed.  -->
       <!-- 2025-06-18 ebb: JUST constraining this to output the AI (Analytic Mechanisms) chapter -->
       
       <xsl:for-each select="child::div[@type='div1'][not(@xml:id='DEPRECATIONS') and not(starts-with(@xml:id, 'REF-'))](:[@xml:id='USE']:)">
           <xsl:variable name="chap" select="current()" as="element()"/>

         <xsl:choose> 
             <xsl:when test="$P5-chapters//div[@xml:id = current()/@xml:id]/child::p"> 
             <xsl:variable name="paras" as="element()*" select="$P5-chapters//div[@xml:id = current()/@xml:id]/child::p"/>
                 <xsl:variable name="targets" as="item()*" select="$P5-chapters/div[@xml:id = current()/@xml:id]/child::p//ptr/@target ! normalize-space()"/>
            <xsl:sequence select=" map {
               'CHAPTER': $chap/head ! normalize-space(),
               'ID': $chap/@xml:id ! string(),
               'CONTAINS-SECTIONS': array { nf:chapterDivPull($chap/@xml:id, 'div1', 'SUBSECTION') },
               'CONTAINS-PARAS': array {nf:paraPuller($paras)},
               'RELATES-TO': nf:linkPuller($targets),
               'CONTAINS-CITATION' : 'Unpack BIB cites here',
               'CONTAINS-SPECS' : 'nf:specPuller() coming here'
               } 
               "/>
             </xsl:when>
             <xsl:otherwise>
                 
               <xsl:sequence select=" map {
                     'CHAPTER': $chap/head ! normalize-space(),
                     'ID': $chap/@xml:id ! string(),
                     'CONTAINS-SECTIONS': array { nf:chapterDivPull($chap/@xml:id, 'div1', 'SUBSECTION') }
                     } 
                     "/> 
             </xsl:otherwise>
         
         </xsl:choose>
       </xsl:for-each>
        </xsl:variable>
        
        <xsl:sequence select=" $chapters "/>
    </xsl:template>
    
   
  
    
</xsl:stylesheet>