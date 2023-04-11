package com.company.AggiePathfinder.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import javax.persistence.Entity;
import java.io.Serializable;

// Specifies that the class is an entity and is mapped to a database table.
@Entity
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Building implements Serializable
{

}
