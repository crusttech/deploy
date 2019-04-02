.PHONY: all build plesk-crust plesk-crust-messaging plesk-crust-crm

all:
	drone exec

build: plesk-crust plesk-crust-messaging plesk-crust-crm

plesk-crust:
	@echo Updating $@
	@cp config.crust-db.env.example $@/
	@cat .env.example | grep -v DIDMOS > $@/.env.example

# generate messaging specific config (common, system, messaging)

plesk-crust-messaging:
	@echo Updating $@
	@rsync --exclude README.md -a plesk-crust/ $@/
	@cat config.crust-api.env.example | egrep -v '^(RBAC|SUBSCR)' > $@/config.crust-api.env.example
	@echo >> $@/config.crust-api.env.example
	@cat config.crust-api-system.env.example >> $@/config.crust-api.env.example
	@echo >> $@/config.crust-api.env.example
	@cat config.crust-api-messaging.env.example >> $@/config.crust-api.env.example
	@awk -i inplace 'BEGIN{RS="";ORS="\n\n"}1' $@/config.crust-api.env.example

# generate crm specific config (common, system, messaging, crm)

plesk-crust-crm:
	@echo Updating $@
	@rsync --exclude README.md -a plesk-crust/ $@/
	@cat config.crust-api.env.example | egrep -v '^(RBAC|SUBSCR)' > $@/config.crust-api.env.example
	@echo >> $@/config.crust-api.env.example
	@cat config.crust-api-system.env.example >> $@/config.crust-api.env.example
	@echo >> $@/config.crust-api.env.example
	@cat config.crust-api-messaging.env.example >> $@/config.crust-api.env.example
	@echo >> $@/config.crust-api.env.example
	@cat config.crust-api-crm.env.example >> $@/config.crust-api.env.example
	@awk -i inplace 'BEGIN{RS="";ORS="\n\n"}1' $@/config.crust-api.env.example
