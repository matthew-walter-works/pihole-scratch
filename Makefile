PIHOLE_CONTAINER_NAME=pihole
PIHOLE_PASSWORD=changeme
PIHOLE_WEB_PORT=8080
PIHOLE_DNS=127.0.0.1

.PHONY: default pull run stop start restart start

default: run

pull:
	docker pull pihole/pihole:latest

.PHONY: run
run: pull
	docker run -d \
	  --name $(PIHOLE_CONTAINER_NAME) \
	  -e TZ="America/New_York" \
	  -e WEBPASSWORD=$(PIHOLE_PASSWORD) \
	  -p 53:53/tcp \
	  -p 53:53/udp \
	  -p $(PIHOLE_WEB_PORT):80 \
	  --restart=unless-stopped \
	  --dns=127.0.0.1 --dns=1.1.1.1 \
	  -v "/etc/pihole/:/etc/pihole/" \
	  -v "/etc/dnsmasq.d/:/etc/dnsmasq.d/" \
	  pihole/pihole:latest

	@echo "Pi-hole is running!"
	@echo "Access the web interface at: http://localhost:$(PIHOLE_WEB_PORT)/admin"
	@echo "Login password: $(PIHOLE_PASSWORD)"
	@echo "To stop Pi-hole: docker stop $(PIHOLE_CONTAINER_NAME)"
	@echo "To start it again: docker start $(PIHOLE_CONTAINER_NAME)"
	@echo "====================================="
	@echo "Configure your macOS laptop to use Pi-hole:"
	@echo "1. Open System Settings."
	@echo "2. Select Network, then choose your active connection (Wi-Fi or Ethernet)."
	@echo "3. Click Details or Advanced."
	@echo "4. Go to the DNS tab."
	@echo "5. Remove any existing DNS servers and add $(PIHOLE_DNS)."
	@echo "6. Click OK and Apply."
	@echo "7. Restart your network connection to apply changes."
	@echo "====================================="

stop:
	docker stop $(PIHOLE_CONTAINER_NAME)

.PHONY: start
start:
	@if [ -z "$(shell docker ps -a -q -f name=$(PIHOLE_CONTAINER_NAME))" ]; then \
		echo "Container does not exist. Creating it..."; \
		$(MAKE) run; \
	else \
		docker start $(PIHOLE_CONTAINER_NAME); \
	fi

restart: stop start
