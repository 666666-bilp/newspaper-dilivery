package model;

import java.io.Serializable;

public class DeliveryArea implements Serializable {
    private int id;
    private int delivererId;
    private int communityId;
    private String assignedDate;
    // Display fields
    private String delivererName;
    private String communityName;

    public DeliveryArea() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getDelivererId() { return delivererId; }
    public void setDelivererId(int delivererId) { this.delivererId = delivererId; }
    public int getCommunityId() { return communityId; }
    public void setCommunityId(int communityId) { this.communityId = communityId; }
    public String getAssignedDate() { return assignedDate; }
    public void setAssignedDate(String assignedDate) { this.assignedDate = assignedDate; }
    public String getDelivererName() { return delivererName; }
    public void setDelivererName(String delivererName) { this.delivererName = delivererName; }
    public String getCommunityName() { return communityName; }
    public void setCommunityName(String communityName) { this.communityName = communityName; }
}
