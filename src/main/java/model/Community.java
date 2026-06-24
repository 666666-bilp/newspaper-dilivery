package model;

import java.io.Serializable;

public class Community implements Serializable {
    private int id;
    private String name;
    private String address;

    public Community() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
}
