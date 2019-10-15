<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sf="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
    version="2.0">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

    <!-- General template copies all xml nodes -->
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
