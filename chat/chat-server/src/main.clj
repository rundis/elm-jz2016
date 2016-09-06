(ns main
  (:gen-class)
  (:require [org.httpkit.server :refer [send! with-channel on-close on-receive run-server]]
            [ring.middleware.file-info :refer [wrap-file-info]]
            [clojure.tools.logging :as log]
            (compojure [core :refer [defroutes GET]]
                       [route :refer [files not-found]]
                       [handler :refer [site]]
                       [route :refer [not-found]])))


(defonce channels (atom []))


(defn connect! [channel]
 (log/info "channel open")
 (swap! channels conj channel))

(defn disconnect! [channel status]
 (log/info "channel closed:" status)
 (swap! channels #(remove #{channel} %)))

(defn notify-clients [msg]
   (log/info (str "Notifying " (count @channels) " with msg: " msg))
  (doseq [channel @channels]
     (send! channel msg)))


(defn ws-handler [request]
 (with-channel request channel
               (connect! channel)
               (on-close channel (partial disconnect! channel))
               (on-receive channel #(notify-clients %))))


(defroutes chartrootm
  (GET "/ws" []  ws-handler)
  (files "" {:root "static"})
  (not-found "<p>Page not found.</p>" ))

(defn- wrap-request-logging [handler]
  (fn [{:keys [request-method uri] :as req}]
    (let [resp (handler req)]
      (log/info (name request-method) (:status resp)
            (if-let [qs (:query-string req)]
              (str uri "?" qs) uri))
      resp)))

(defn -main [& args]
  (run-server (-> #'chartrootm site wrap-request-logging) {:port 9899})
  (log/info "server started. http://127.0.0.1:9899"))
