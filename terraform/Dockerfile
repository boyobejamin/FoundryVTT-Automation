ARG NEXUS_PROXY_URL
ARG TERRAFORM_VERSION "latest"
ARG ALPINE_VERSION "latest"
FROM ${NEXUS_PROXY_URL}/hashicorp/terraform:${TERRAFORM_VERSION} as terraform-builder
FROM ${NEXUS_PROXY_URL}/alpine:${ALPINE_VERSION}


COPY --from=terraform-builder /bin/terraform /bin/terraform