package com.simonmdsn.rabbit;

import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RabbitRepository extends CrudRepository<RabbitMessage, Long> {
}
