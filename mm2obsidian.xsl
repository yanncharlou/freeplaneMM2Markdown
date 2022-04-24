<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
MINDMAPEXPORTFILTER md;markdown Obsidian

v. 0.4
		
This code released under the GPL. : (http://www.gnu.org/copyleft/gpl.html) 
Document : mm2obsidian.xsl 
Created	on : 24 April, 2022
Authors : Yann Charlou (based on work by others see below)
Description: Transforms freeplane mm to markdown md suited for obsidian. 
* Nodes with childs become headings and subheadings, Node without child and Notes become paragraphs. 
* Attributes of root node become document metadata. 
* Details are not handled. 
* HTML tables are converted to Pandoc pipe table format.
* Tested with Pandoc-flavored markdown.

May not work:
* Pandoc markdown style links/references

Please test and suggest improvements to author, or feel free to customize
while crediting previous authors.

******************************************************************************
Based on mm2markdown.xsl
******************************************************************************
Created	on : 20 November, 2013 
Authors : Lee Hachadoorian Lee.Hachadoorian@gmail.com and Peter Yates pyates@gmail.com
Description: Transforms freeplane mm to markdown md.

******************************************************************************
Based on mm2text.xsl, original notice appears below
******************************************************************************
Document : mm2text.xsl 
Created	on : 01 February 2004, 17:17 
Author : joerg feuerhake joerg.feuerhake@free-penguin.org 
Description: transforms freeplane mm
format to html, handles crossrefs and adds numbering. feel free to
customize it while leaving the ancient authors mentioned. thank you
ChangeLog: See: http://freeplane.sourceforge.net/
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"/>
	<xsl:key name="refid" match="node" use="@ID" />

	<!-- Template to print header #signs  -->
	<xsl:template name="numberSign">
		<xsl:param name="howMany">1</xsl:param>
		<xsl:if test="$howMany &gt; 0 and ($howMany &lt; 7)">
			<!-- Add 1 number signs (#) to result tree. -->
			<xsl:text>#</xsl:text>
			<!-- Print remaining ($howMany - 1) number signs. -->
			<xsl:call-template name="numberSign">
				<xsl:with-param name="howMany" select="$howMany - 1"/>
			</xsl:call-template>
		</xsl:if>
        <xsl:if test="$howMany = 7">
			<xsl:text>*</xsl:text>
		</xsl:if>
		<xsl:if test="$howMany = 8">
			<xsl:text>  +</xsl:text>
		</xsl:if>
		<xsl:if test="$howMany = 9">
			<xsl:text>    -</xsl:text>
		</xsl:if>
		<xsl:if test="$howMany = 10">
			<xsl:text>      *</xsl:text>
		</xsl:if>
		<xsl:if test="$howMany = 11">
			<xsl:text>        +</xsl:text>
		</xsl:if>
		<xsl:if test="$howMany = 12">
			<xsl:text>          -</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- Template to print table header separator row  -->
	<xsl:template name="tableHeaderDashes">
		<xsl:param name="howManyCols">1</xsl:param>
		<xsl:if test="$howManyCols &gt; 0">
			<!-- Add left pipe and dashes to result tree. -->
			<xsl:text>| ------ </xsl:text>
			<!-- Print remaining ($howManyCols - 1) pipe dashes. -->
			<xsl:call-template name="tableHeaderDashes">
				<xsl:with-param name="howManyCols" select="$howManyCols - 1"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$howManyCols = 0">
			<xsl:text>|</xsl:text>
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="/map">
		<xsl:apply-templates select="node"/>
	</xsl:template>

	<xsl:template match="richcontent[text]">
		<xsl:text>&#xA;</xsl:text>
		<xsl:value-of select="text" />
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template match="richcontent">
		<xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates />
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="child::text()[normalize-space(.) = '']"/>
	<xsl:template match="child::text()">
		<xsl:value-of select="translate(normalize-space(.),'&#160;',' ')" />
	</xsl:template>

	<!-- Insert newline for html breaks, paras, etc. -->
	<xsl:template match="p|br|div|pre|ol|ul">
		<xsl:if test="preceding-sibling::*">
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="li">
		<xsl:if test="preceding-sibling::*">
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
		<xsl:if test="parent::ol">
		    <xsl:number/>
			<xsl:text>. </xsl:text>
		</xsl:if>
		<xsl:if test="parent::ul">
			<xsl:text>- </xsl:text>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Convert Headings to markdown syntax -->
	<xsl:template match="h1">
		<xsl:text>&#xA;&#xA;</xsl:text>
		<xsl:text># </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="h2">
		<xsl:text>&#xA;&#xA;</xsl:text>
		<xsl:text>## </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="h3">
		<xsl:text>&#xA;&#xA;</xsl:text>
		<xsl:text>### </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="h4">
		<xsl:text>&#xA;&#xA;</xsl:text>
		<xsl:text>#### </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="h5">
		<xsl:text>&#xA;&#xA;</xsl:text>
		<xsl:text>##### </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="h6">
		<xsl:text>&#xA;&#xA;</xsl:text>
		<xsl:text>###### </xsl:text>
		<xsl:apply-templates/>
	</xsl:template>

	<!-- Convert Italics to markdown syntax -->
	<xsl:template match="i|em">
		<xsl:text> *</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>* </xsl:text>		
	</xsl:template>

	<!-- Convert Bold to markdown syntax -->
	<xsl:template match="b|strong">
		<xsl:text> **</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>** </xsl:text>		
	</xsl:template>

	<!-- Strikethrough formatting -->
	<xsl:template match="strike">
		<xsl:text> ~~</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>~~ </xsl:text>		
	</xsl:template>

	<!-- Convert <hr> to markdown horizontal rule -->
	<xsl:template match="hr">
		<xsl:text>*  *  *  *  *</xsl:text>
	</xsl:template>

	<!-- Convert html table to pandoc pipe table -->
	<xsl:template match="table">
		<xsl:text>&#xA;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tr">
		<xsl:if test="count(preceding-sibling::tr)=1">
			<xsl:call-template name="tableHeaderDashes">
				<xsl:with-param name="howManyCols" select="count(td)" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates />
		<xsl:text>&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="td|th">
		<xsl:text>| </xsl:text>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="node">
		<xsl:variable name="thisid" select="@ID" />
		<xsl:variable name="target" select="arrowlink/@DESTINATION" />
		<xsl:choose>
			<!-- Root node attributes create yaml block -->
			<xsl:when test="count(ancestor::*) = 1">
				<!-- Only create yaml block if there are attributes -->
				<xsl:if test="count(attribute) > 0">
					<xsl:text>&#xA;</xsl:text>
					<xsl:text>---&#xA;</xsl:text>
					<xsl:apply-templates select="attribute" />
					<xsl:text>---</xsl:text>
				</xsl:if>
			</xsl:when>
    		<!-- node text prefix for non root -->
			<xsl:when test="@TEXT">
				<xsl:text>&#xA;</xsl:text>
                <!-- Create the headers using number signs 
    	            Only if it has at least one child or richcontent
				-->
        		<xsl:if test="node or richcontent">
    				<xsl:call-template name="numberSign">
    					<xsl:with-param name="howMany" select="count(ancestor::*) - 1"/>
    				</xsl:call-template>
                    <xsl:text> </xsl:text>
		        </xsl:if>                
			</xsl:when>
        </xsl:choose>

		<!-- Node text -->
		<xsl:if test="@TEXT">
            <xsl:value-of select="@TEXT" />
			<xsl:text>&#xA;</xsl:text>
    	</xsl:if>
		<xsl:apply-templates select="richcontent[@TYPE='NODE']"/>
		<xsl:apply-templates select="richcontent[@TYPE='DETAILS']"/>
		<xsl:apply-templates select="richcontent[@TYPE='NOTE']"/>
		<xsl:if test="arrowlink/@DESTINATION != ''">
			<xsl:text> (see:</xsl:text>
			<xsl:for-each select="key('refid', $target)">
				<xsl:value-of select="@TEXT" />
			</xsl:for-each>
			<xsl:text>)</xsl:text>
		</xsl:if>
		<xsl:apply-templates select="node"/>
	</xsl:template>

	<!-- Attribute template -->
	<xsl:template match="attribute">
		<!-- yaml wants lowercase field names -->
		<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:value-of select="translate(@NAME, $uppercase, $lowercase)" />: '<xsl:value-of select="@VALUE" />'
		<xsl:text>&#13;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
