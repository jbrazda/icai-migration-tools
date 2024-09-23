<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sfd="http://schemas.active-endpoints.com/appmodules/screenflow/2010/10/avosScreenflow.xsd"
    
	version="2.0">
	<xsl:output method="xml" indent="yes"  omit-xml-declaration="yes" />
	<!-- Allowed Groups can be a comma separated List 
	This Stylesheet sets the Allowed Consumer in the process Service Definitions  such as
	
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
	<xsl:param name="groupMap">file:/C:/Users/NCVJ9B/git/github/icai-migration-tools/sample-data/test-configs/group-map.xml</xsl:param>
	<xsl:param name="usersMap">file:/C:/Users/NCVJ9B/git/github/icai-migration-tools/sample-data/test-configs/user-map.xml</xsl:param>
	
	<xsl:variable name="currentAssetName" select="/*/*:Item/*:Name/text()"></xsl:variable>
	<xsl:variable name="allowedGroups" select="doc($groupMap)//Group[process/text() = $currentAssetName]/@Name"></xsl:variable>
	<xsl:variable name="allowedUsers" select="doc($usersMap)//User[process/text() = $currentAssetName]/@Name"></xsl:variable>
	
	<!-- General template copies all xml nodes -->
	<xsl:template match="@*|node()" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="sfd:deployment">
        <xsl:copy>
        	<xsl:apply-templates select="@*|node()"/>
        	<xsl:if test="not(sfd:rest) and ( not(empty($allowedGroups)) or not(empty($allowedUsers)))">
                <sfd:rest>
                    <xsl:if test="not(empty($allowedGroups))">
                    <sfd:allowedGroups>
                        <xsl:for-each select="$allowedGroups">
                            <sfd:group>
                                <xsl:value-of select="."/>
                            </sfd:group>
                        </xsl:for-each>
                    </sfd:allowedGroups>
                    </xsl:if>
                    <xsl:if test="not(empty($allowedUsers))">
                    <sfd:allowedUsers>
                        <xsl:for-each select="$allowedUsers">
                           <sfd:user>
                     	      <xsl:value-of select="."/>
                           </sfd:user>
                        </xsl:for-each>
                    </sfd:allowedUsers>
                    </xsl:if>
                </sfd:rest>
            </xsl:if>
        </xsl:copy>
	</xsl:template>
	
    <xsl:template match="sfd:rest">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()[not(local-name(.) = ('allowedGroups','allowedUsers'))]"/>
	        <xsl:if test="not(empty($allowedGroups))">
	            <sfd:allowedGroups>
	                <xsl:for-each select="$allowedGroups">
	                    <sfd:group>
	                        <xsl:value-of select="."/>
	                    </sfd:group>
	                </xsl:for-each>
	            </sfd:allowedGroups>
            </xsl:if>
            <xsl:if test="not(empty($allowedUsers))">
	            <sfd:allowedUsers>
	                <xsl:for-each select="$allowedUsers">
	                   <sfd:user>
	             	      <xsl:value-of select="."/>
	                   </sfd:user>
	                </xsl:for-each>
	            </sfd:allowedUsers>
            </xsl:if>                  
            <xsl:if test="sfd:event">
                <xsl:copy-of select="sfd:event"/>
            </xsl:if> 
        </xsl:copy>
    </xsl:template>
	
</xsl:stylesheet>
