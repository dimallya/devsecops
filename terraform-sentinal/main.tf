data "vault_kubernetes_service_account_token" "kube_token" {
  backend              = "openshift"
  role                 = "devsecops-sa-role"
  kubernetes_namespace = var.namespace
}

resource "kubernetes_limit_range" "devsecops" {
  metadata {
    name = "devsecops-default"
    namespace = var.namespace
  }
  spec {
    limit {
      type = "Pod"
      max = {
        cpu    = "2500m"
        memory = "1024M"
      }
    }
    limit {
      type = "PersistentVolumeClaim"
      min = {
        storage = "24M"
      }
    }
    limit {
      type = "Container"
      default = {
        cpu    = "50m"
        memory = "24M"
      }
    }
  }
}
resource "kubernetes_pod" "nginx" {
  metadata {
    labels = {
      app     = "nginx"
    }
    name = "nginx-pod"
  }

  spec {
    container {

      # Missing or incorrect run_as_non_root setting
      security_context {
        run_as_user = 0
      }

      image = "nginx:1.7.8"
      name  = "nginx"

      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_deployment" "digital_bank" {
  metadata {
    name      = "digital-bank-deployment"
    namespace = var.namespace
    labels = {
      app = "digital-bank"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "digital-bank"
      }
    }

    template {
      metadata {
        labels = {
          app = "digital-bank"
        }
      }

      spec {
        container {
          name  = "digital-bank"
          image = "digisic/digitalbank:latest"

          port {
            name           = "db-bank-port"
            container_port = 8443
          }

          env {
            name  = "LOGGING_LEVEL_IO_DEMO_BANK"
            value = "INFO"
          }
          env {
            name  = "SPRING_ARTEMIS_MODE"
            value = "native"
          }
          env {
            name  = "SPRING_ARTEMIS_HOST"
            value = "digital-bank-broker-svc"
          }
          env {
            name  = "SPRING_ARTEMIS_PORT"
            value = "61616"
          }
          env {
            name  = "SPRING_ARTEMIS_USER"
            value = "admin"
          }
          env {
            name  = "SPRING_ARTEMIS_PASSWORD"
            value = "admin"
          }
          env {
            name  = "IO_DIGISIC_CREDIT_ENABLED"
            value = "true"
          }
          env {
            name  = "IO_DIGISIC_CREDIT_PROTOCOL"
            value = "http"
          }
          env {
            name  = "IO_DIGISIC_CREDIT_HOST"
            value = "digital-bank-credit-svc"
          }
          env {
            name  = "IO_DIGISIC_CREDIT_PORT"
            value = "8085"
          }
          env {
            name  = "IO_DIGISIC_CREDIT_CONTEXT-PATH-PATH"
            value = "/credit"
          }
          env {
            name  = "IO_DIGISIC_CREDIT_USERNAME"
            value = "admin@demo.io"
          }
          env {
            name  = "IO_DIGISIC_CREDIT_PASSWORD"
            value = "Demo123!"
          }
          env {
            name  = "IO_DIGISIC_PARTNER_CREDIT_APP_REQUEST"
            value = "CREDIT.APP.REQUEST"
          }
          env {
            name  = "IO_DIGISIC_PARTNER_CREDIT_APP_RESPONSE"
            value = "CREDIT.APP.RESPONSE"
          }
          env {
            name  = "IO_DIGISIC_BANK_ATM_PROTOCOL"
            value = "https"
          }
          env {
            name  = "IO_DIGISIC_BANK_ATM_HOST"
            value = "bankingservices.io"
          }
          env {
            name  = "IO_DIGISIC_BANK_ATM_PORT"
            value = ""
          }
          env {
            name  = "IO_DIGISIC_BANK_VISA_PROTOCOL"
            value = "https"
          }
          env {
            name  = "IO_DIGISIC_BANK_VISA_HOST"
            value = "creditservices.io"
          }
          env {
            name  = "IO_DIGISIC_BANK_VISA_PORT"
            value = ""
          }
          env {
            name  = "IO_DIGISIC_BANK_OBP_ENABLED"
            value = "true"
          }
          env {
            name  = "IO_DIGISIC_BANK_OBP_CONSUMER_KEY"
            value = "vwfpvwfr1kngt0up2jelebzmvxrhst4vhxvw1jm3"
          }
          env {
            name  = "IO_DIGISIC_BANK_OBP_VERSION"
            value = "v4.0.0"
          }
          env {
            name  = "IO_DIGISIC_BANK_OBP_PROTOCOL"
            value = "https"
          }
          env {
            name  = "IO_DIGISIC_BANK_OBP_HOST"
            value = ""
          }
          env {
            name  = "IO_DIGISIC_BANK_OBP_PORT"
            value = ""
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "digital_bank_svc" {
  metadata {
    name      = "digital-bank-svc"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "LoadBalancer"
    }

    type = "LoadBalancer"

    port {
      name        = "https"
      port        = 8443
      target_port = "db-bank-port"
    }
  }
}
