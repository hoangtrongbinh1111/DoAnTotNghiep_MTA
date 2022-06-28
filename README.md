- Folder Tool dùng để lưu các công cụ, thư viện xử lý (0_Tool)
- Folder Dataset để lưu các dữ liệu xử lý cho bài toán
    + 1_IoT_Trace_Dataset_Public: Dùng để lưu dữ liệu public dataset từ trên các trang public (1_Pcap)
    + 2_Processed_Dataset: Dùng để lưu các dữ liệu đã được xử lý từ raw data (2_Session)
        + PCAP_by_Session: Tách dữ liệu thành các single session (AllLayers)
        + PCAP_by_MAC: Chia các file pcap single session về các folder theo source MAC (AllLayers_MAC)
    + 3_Standard_Dataset: Dùng để lưu các dữ liệu xử lý chuẩn hóa từ 2_Processed_Dataset (3_ProcessedSession)
    + 4_Image_Dataset: Dùng để lưu các dữ liệu convert sang dạng ảnh để visualize (4_Png)
    + 5_IDX_Dataset: Dùng để lưu dữ liệu dạng IDX được convert từ ảnh trong 4_Image_Dataset để tích hợp làm đầu vào mạng học sâu (5_Mnist)
- Folder checkpoint để lưu model huấn luyện
- Folder logs để lưu tiến trình huấn luyện

-----------------------------------------------------------
- Usage
1. pwsh 1_Pcap2Session.ps1 -s
2. rm -rf *UDP* / find -name "*UDP*" -delete
3. python 2_Pcap2MAC.py
4. pwsh 3_Standard_Dataset.ps1 -l -s 
5. python 4_Session2Png.py
6. python 5_Png2Mnist.py