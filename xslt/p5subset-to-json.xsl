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
    
    <xsl:variable name="P5-chapters" as="document-node()+" select="collection('../p5-chapters/en-2025-06-17/?select=*.xml')"/>
     <!-- 2025-06-17 ebb: The directory path will change with updates to the P5 subset saved to the repo. We are removing the following:
     * BIBL (too much information indirectly related to the elements  
     * file named "DEPRECATION" (contains little explicit information)
     * files with names starting REF- (mostly empty files that represent from the element / attribute / class / module specs)
     -->
   
    <xsl:function name="nf:chapterDivPull" as="map(*)*">
        <xsl:param name="input-id" as="xs:string"/>
        <xsl:param name="whichDiv" as="xs:string"/>
        <xsl:param name="sectionLevel" as="xs:string"/>
      <!--  <xsl:sequence select="array{
            for $div in ($P5-chapters//div[@type=$whichDiv and @xml:id =$input-id ]/div[@type])
            return map {
            $div/@xml:id : $div/head ! string(),
            'CONTAINS-WHATNOW?' : 'CALL-ANOTHER-FUNCTION, OR THE SAME FUNCTION? HMMM.'
            }
            }"/>-->
        <xsl:for-each select="$P5-chapters//div[@type=$whichDiv and @xml:id =$input-id ]/div[@type and @xml:id]">
         
           <xsl:choose> 
               <xsl:when test="current()[child::div/@type]">
                   <xsl:sequence select="map {
                       'SECTION' : current()/head ! string(),
                       'ID': current()/@xml:id ! string(),
                       'CONTAINS-'||$sectionLevel : array { nf:chapterDivPull(current()/@xml:id, current()/@type, 'NESTED-SUBSECTION') }
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
           <xsl:for-each select="child::TEI[1]/text/*">
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
            'P5subset-text': current-dateTime(),
            'CONTAINS-PARTS' : array { $partInfo }
            }"/>
       
    </xsl:template>
    
    <xsl:template match="text/*" as="map(*)*">      
   <xsl:variable name="chapters" as="array(*)*">
       <!--ebb: NOTE: Here we are excluding the P5 Subset file's references to the REF- and Deprecations files we've removed.  -->
       <!-- 2025-06-18 ebb: JUST constraining this to output the AI (Analytic Mechanisms) chapter -->
            <xsl:sequence select="array {
                for $chap in child::div[@type='div1'][not(@xml:id='DEPRECATIONS') and not(starts-with(@xml:id, 'REF-'))] return
                map {
                  'CHAPTER': $chap/head/text(),
                  'ID': $chap/@xml:id ! string(),
                  'CONTAINS-SECTIONS': array { nf:chapterDivPull($chap/@xml:id, 'div1', 'SUBSECTION') }
                  }
                }
               "/> 
        </xsl:variable>
        
        <xsl:sequence select="map {
            'CHAPTERS': $chapters
            }"/>
    </xsl:template>
    
   
  
    
</xsl:stylesheet>