(defproject org.httpkit/chat-websocket "1.0"
  :description "Realtime chat by utilizing http-kit's websocket support"
  :dependencies [[org.clojure/clojure "1.8.0"]
                 [ring/ring-core "1.4.0"]
                 [compojure "1.5.0"]
                 [cheshire "5.6.1"]
                 [org.clojure/tools.logging "0.2.3"]
                 [ch.qos.logback/logback-classic "1.1.7"]
                 [http-kit "2.1.19"]
                 [javax.servlet/servlet-api "2.5"]]
  :min-lein-version "2.5.0"
  :main main
  :plugins []
  :license {:name "Apache License, Version 2.0"
            :url "http://www.apache.org/licenses/LICENSE-2.0.html"})
