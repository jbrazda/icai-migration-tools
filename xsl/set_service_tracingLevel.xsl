<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
	version="2.0">
	<xsl:output method="xml" indent="yes"  omit-xml-declaration="yes" />
	<!-- Tracing Level can one of the following  
       - none
       - terse
       - normal
       - verbose
	-->
	<xsl:param name="tracingLevel">none</xsl:param>  


	<!-- General template copies all xml nodes -->
	<xsl:template match="@*|node()" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="sfd:deployment/@tracingLevel">
        <xsl:attribute name="tracingLevel">
        	<xsl:value-of select="$tracingLevel"/>
        </xsl:attribute>
	</xsl:template>
	
    <xsl:template match="sfd:deployment[not(@tracingLevel)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
	        <xsl:attribute name="tracingLevel">
	        	<xsl:value-of select="$tracingLevel"/>
	         </xsl:attribute>
	        <xsl:apply-templates select="node()"/> 
        </xsl:copy>
    </xsl:template>
	
</xsl:stylesheet>
