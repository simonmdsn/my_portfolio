package com.simonmdsn.rabbit;

import lombok.Data;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.amqp.core.*;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.amqp.rabbit.listener.adapter.MessageListenerAdapter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.sound.midi.Receiver;

@Component
@RequiredArgsConstructor
public class RabbitMessageServer {
    public static final String topic = "chat";
    private final RabbitRepository rabbitRepository;
    private final RabbitTemplate template;

    @Bean
    public TopicExchange topic() {
        return new TopicExchange(topic);
    }

    private static class ReceiverConfig {

        @Bean
        Queue queue() {
            return new Queue(topic);
        }

        @Bean
        Binding binding(TopicExchange topic, Queue queue) {
            return BindingBuilder.bind(queue).to(topic).with("*");
        }

    }
        @RabbitListener(queues = "#{queue.name}")
        public void receive(String in) {
            System.out.println("Received " + in);
        }

    @Scheduled(fixedDelay = 1000, initialDelay = 500)
    public void send() {
        String message = "Hello World!";
        this.template.convertAndSend(topic, message);
        System.out.println(" [x] Sent '" + message + "'");
    }
}
