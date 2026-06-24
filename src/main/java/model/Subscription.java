package model;

import java.io.Serializable;

public class Subscription implements Serializable {
    private int id;
    private int customerId;
    private int newspaperId;
    private int quantity;
    private String startDate;
    private String endDate;
    private String status;
    // Display fields from join
    private String customerName;
    private String newspaperName;
    private String communityName;
    private double totalAmount;
    private String createdAt;

    public Subscription() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getCustomerId() { return customerId; }
    public void setCustomerId(int customerId) { this.customerId = customerId; }
    public int getNewspaperId() { return newspaperId; }
    public void setNewspaperId(int newspaperId) { this.newspaperId = newspaperId; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }
    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }
    public String getNewspaperName() { return newspaperName; }
    public void setNewspaperName(String newspaperName) { this.newspaperName = newspaperName; }
    public String getCommunityName() { return communityName; }
    public void setCommunityName(String communityName) { this.communityName = communityName; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
