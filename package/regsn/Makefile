include $(TOPDIR)/rules.mk

PKG_NAME:=regsn
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/regsn
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=regsn
endef

define Package/regsn/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/regsn $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,regsn))
