<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:eg ="http://www.tei-c.org/ns/Examples"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:nf="http://newtfire.org"
    exclude-result-prefixes="xs math eg"
    version="4.0">
    
    <xsl:output method="json" indent="yes"/>
    
    <xsl:variable name="P5-chapters" as="document-node()+" select="collection('../p5-chapters/en-2025-06-17/?select=*.xml')"/>
     <!-- 2025-06-17 ebb: The directory path will change with updates to the P5 subset saved to the  -->
   
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
                       current()/@xml:id : current()/head ! string(),
                       'CONTAINS-'||$sectionLevel : array { nf:chapterDivPull(current()/@xml:id, current()/@type, 'NESTED-SUBSECTION') }
                       }"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="map {
                    current()/@xml:id : current()/head ! string()
                    }"/>

            </xsl:otherwise>
           </xsl:choose>
            
        </xsl:for-each>
    </xsl:function>
    
    <xsl:template match="/">
        <xsl:variable name="chapterMaps" as="map(*)*">
            <xsl:apply-templates select="child::TEI[1]/text/*"/>
        </xsl:variable>
        
        <xsl:variable name="process" as="array(*)*">
          <xsl:sequence select="array{ 
              for $part in (child::TEI[1]/text/*)
              return map {
               'PART' : $part/name(),
               'CONTAINS-CHAPTERS': array { $chapterMaps
               }
               }
            }"/>
        </xsl:variable>
        
        <xsl:sequence select="map {
            'P5subset-text': current-dateTime(),
            'CONTAINS-PARTS' :  $process
            }"/>
    </xsl:template>
    
    <xsl:template match="text/*" as="map(*)*">      
   <xsl:variable name="chapters" as="array(*)*">
            <xsl:sequence select="array {
                for $chap in child::div[@type='div1'] return
                map {
                  $chap/@xml:id : $chap/head/text(),
                  'CONTAINS-SECTION': array { nf:chapterDivPull($chap/@xml:id, 'div1', 'SUBSECTION') }
                  }
                }
               "/> 
        </xsl:variable>
        
        <xsl:sequence select="map {
           
            'CHAPTERS': $chapters
            }"/>
    </xsl:template>
    
   
  
    
</xsl:stylesheet>