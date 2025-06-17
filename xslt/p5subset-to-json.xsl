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
   
    <xsl:function name="nf:chapterCollPull" as="item()*">
        <xsl:param name="input-id" as="xs:string"/>
       <xsl:param name="input2" as="xs:string"/>-
        <xsl:sequence select="array{
            for $div in ($P5-chapters/div[@type='div1' and @xml:id =$input-id ]/div[@type='div2'])
            return map {
            $div/@xml:id : $div/head ! string(),
            'CONTAINS-WHATNOW?' : 'CALL-ANOTHER-FUNCTION, OR THE SAME FUNCTION? HMMM.'
            }
            }"/>
    </xsl:function>
    
    <xsl:template match="/">
        
        <xsl:variable name="COLLTESTER">
            <xsl:apply-templates select="$P5-chapters//div[@type='div1'][1]/head/text()"/>
        </xsl:variable>
        
        <xsl:variable name="chapterMaps" as="map(*)*">
            <xsl:apply-templates select="child::TEI[1]/text/*"/>
        </xsl:variable>
        
        <xsl:variable name="process" as="array(*)*">
          <xsl:sequence select="array{ for $section in (child::TEI[1]/text/*)
               return map {
               'section' : $section/name(),
               'CONTAINS-CHAPTERS': array { $chapterMaps

               }
               }
            }"/>
        </xsl:variable>
        
        <xsl:sequence select="map {
            'P5subset-text': current-dateTime(),
            'CONTAINS-PARTS' :  $process,
            'CONTAINS-COLLSTUFF': $COLLTESTER
            }"/>
      
        
 
    </xsl:template>
    
    <xsl:template match="text/*" as="map(*)*">
        
     
      
   <xsl:variable name="chapters" as="array(*)*">
            <xsl:sequence select="array {
                for $chap in child::div[@type='div1'] return
                map {
                  $chap/@xml:id : $chap/head/text(),
                  'CONTAINS-SECTION': array {nf:chapterCollPull($chap/@xml:id, 'section')}
                  }
                }
               "/> 
        </xsl:variable>
        
        <xsl:sequence select="map {
           
            'CONTAINS-CHAPTERS': $chapters
            }"/>

    </xsl:template>
    
</xsl:stylesheet>