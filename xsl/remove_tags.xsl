<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
    xmlns:ahe="http://schemas.active-endpoints.com/appmodules/screenflow/2011/06/avosHostEnvironment.xsd"
    xmlns:rep="http://schemas.active-endpoints.com/appmodules/repository/2010/10/avrepository.xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
    <xsl:param name="tagMatchPattern">(,)?(GIT:\w+)</xsl:param>   

    <!-- General template copies all xml nodes -->
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    <!-- Remove GIT: or other tags matching the pattern -->
    <xsl:template match="sfd:tags|ahe:tags|rep:Tags">
        <xsl:copy>
            <xsl:value-of select="replace(.,$tagMatchPattern,'')"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
