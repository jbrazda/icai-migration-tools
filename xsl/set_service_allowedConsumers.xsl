<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
  
	version="2.0">
	<xsl:output method="xml" indent="yes"  omit-xml-declaration="yes" />
	<!-- Allowed Groups can be a comma separated List 
	This XSLT sets the Allowed Consumer in the process Service Definitions  such as
	
		<deployment suspendOnFault="false" tracingLevel="none">
           <targetLocation>CAI</targetLocation>
           <rest>
              <allowedGroups>
                 <group>Developer</group>
                 <group>Service Account</group>
              </allowedGroups>
              <allowedUsers>
                 <user>test.user.dev@natl.com</user>
              </allowedUsers>
              <event eventSource="System Events:Runtime Alert Service"/>
           </rest>
        </deployment>
	 -->
	<xsl:param name="allowedGroups">TBD,TEST</xsl:param>
	<xsl:param name="allowedUsers">test</xsl:param>

	<!-- General template copies all xml nodes -->
	<xsl:template match="@*|node()" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="sfd:deployment">
        <xsl:copy>
        	<xsl:apply-templates select="@*|node()"/>
        	<xsl:if test="not(sfd:rest)">
                <sfd:rest>
                    <sfd:allowedGroups>
                        <xsl:for-each select="tokenize($allowedGroups, ',')">
                            <sfd:group>
                                <xsl:value-of select="."/>
                            </sfd:group>
                        </xsl:for-each>
                    </sfd:allowedGroups>
                    <sfd:allowedUsers>
                        <xsl:for-each select="tokenize($allowedUsers, ',')">
                           <sfd:user>
                     	      <xsl:value-of select="."/>
                           </sfd:user>
                        </xsl:for-each>
                    </sfd:allowedUsers>
                </sfd:rest>
            </xsl:if>
        </xsl:copy>
        <base-uri><xsl:value-of select="base-uri()"/></base-uri>
	</xsl:template>
	
    <xsl:template match="sfd:rest">
        <xsl:copy>
            <!-- copy only elements other than allowedGroups allowedGroups  these to be replaced by the groups provided in parameters -->
            <xsl:apply-templates select="@*|node()[not(local-name(.) = ('allowedGroups','allowedGroups'))]"/>
	        <sfd:allowedGroups>
                <xsl:for-each select="tokenize($allowedGroups, ',')">
                    <sfd:group>
                        <xsl:value-of select="."/>
                    </sfd:group>
                </xsl:for-each>
            </sfd:allowedGroups>
            <sfd:allowedUsers>
                <xsl:for-each select="tokenize($allowedUsers, ',')">
                     <sfd:user>
                     	<xsl:value-of select="."/>
                     </sfd:user>
                </xsl:for-each>
            </sfd:allowedUsers>                  
            <xsl:if test="sfd:event">
                <xsl:copy-of select="sfd:event"/>
            </xsl:if> 
        </xsl:copy>
    </xsl:template>
	
</xsl:stylesheet>
