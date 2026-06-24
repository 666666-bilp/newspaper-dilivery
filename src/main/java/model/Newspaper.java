package model;

import java.io.Serializable;

public class Newspaper implements Serializable {
    private int id;
    private String name;
    private double price;
    private int stock;
    private String type;
    private String createdAt;

    public Newspaper() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
