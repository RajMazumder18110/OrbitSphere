FROM rabbitmq:management-alpine

COPY ./plugins/rabbitmq_delayed_message_exchange-4.0.2.ez /opt/rabbitmq/plugins/

RUN rabbitmq-plugins enable rabbitmq_delayed_message_exchange