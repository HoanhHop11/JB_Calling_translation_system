# Hướng dẫn cho GitHub Copilot Agent

## NGUYÊN TẮC QUAN TRỌNG NHẤT

### 1. LUÔN PHẢN HỒI BẰNG TIẾNG VIỆT
- Tất cả các phản hồi, giải thích, comment trong code PHẢI bằng tiếng Việt
- Chỉ sử dụng tiếng Anh cho tên biến, hàm, class theo chuẩn coding convention

### 2. YÊU CẦU THÔNG TIN THỰC TRƯỚC KHI TIẾP TỤC
- ⚠️ **QUAN TRỌNG**: Khi cần API key, token, credential, hoặc bất kỳ thông tin thực tế nào (như IP address, domain name, secret key), PHẢI DỪNG LẠI và thông báo cho người dùng
- KHÔNG được tự động điền giá trị giả (placeholder) và tiếp tục
- KHÔNG được bỏ qua bước xác nhận thông tin thực
- Phải liệt kê rõ ràng những thông tin cần cập nhật:
  - Tên biến/file cần cập nhật
  - Mô tả ý nghĩa của thông tin đó
  - Cách lấy thông tin (nếu có)
  - Định dạng yêu cầu (nếu có)

### 3. KIỂM TRA TRƯỚC KHI THỰC HIỆN
Trước khi thực hiện bất kỳ thao tác nào:
1. Kiểm tra xem có cần thông tin thực từ người dùng không
2. Nếu có, DỪNG và yêu cầu thông tin
3. Chỉ tiếp tục khi đã có đầy đủ thông tin thực

### 4. HẠN CHẾ TẠO FILE MỚI
- ⚠️ **QUAN TRỌNG**: Trước khi tạo file mới, PHẢI suy nghĩ kỹ xem có thực sự cần thiết không
- Ưu tiên CẬP NHẬT hoặc BỔ SUNG vào file đã có thay vì tạo file mới
- Chỉ tạo file mới khi:
  - File đó là bắt buộc cho chức năng (code, config, script)
  - Không có file phù hợp để gộp nội dung vào
  - Tách file giúp tổ chức tốt hơn (theo convention dự án)
- KHÔNG tạo file documentation/guide/summary trùng lặp
- KHÔNG tạo multiple versions của cùng một tài liệu
- Hỏi người dùng trước khi tạo nhiều file cùng lúc

### 5. ĐỌC VÀ KẾ THỪA TÀI LIỆU CÓ SẴN
- ⚠️ **BẮT BUỘC**: Trước khi bắt đầu làm việc, PHẢI đọc các tài liệu hiện có
- **Quy trình đọc tài liệu**:
  1. Check `DOCUMENTATION-INDEX.md` để biết structure và priority
  2. Đọc file status mới nhất (format: `SYSTEM-STATUS-OCTXX-2025.md`)
  3. Đọc investigation/wrap-up reports nếu có (format: `*-OCTXX.md`)
  4. Đọc ROADMAP để hiểu phase hiện tại
  5. Đọc technical docs trong `docs/` folder nếu cần
- **Khi cập nhật tài liệu**:
  - Update file hiện có thay vì tạo mới
  - Thêm superseded notice vào file cũ nếu tạo version mới
  - Update DOCUMENTATION-INDEX.md với file mới
  - Update README.md nếu có thay đổi quan trọng
- **Naming Convention cho Documentation**:
  - System Status: `SYSTEM-STATUS-OCT<DD>-2025.md`
  - Investigation: `<TOPIC>-INVESTIGATION-OCT<DD>.md`
  - Session Wrap-up: `WRAP-UP-OCT<DD>.md`
  - Roadmap: `ROADMAP-UPDATED-OCT2025.md` (monthly update)
  - Commit Message: `COMMIT-MESSAGE-OCT<DD>-<TOPIC>.txt`

## Thông tin Dự án

### Tổng quan
Dự án: **Hệ thống Videocall Dịch Thuật Real-time Đa Ngôn Ngữ**
- Công nghệ: Docker Swarm, Python, WebRTC, Whisper, FastAPI
- Mục tiêu: Xây dựng hệ thống videocall với dịch thuật tự động thời gian thực
- Đặc điểm: Không có GPU, chỉ sử dụng CPU trên 3 instances Google Cloud
- **Phase hiện tại**: Phase 4-5 (95% - Gateway WebSocket routing issue)
- **Latest Status**: `SYSTEM-STATUS-OCT15-2025.md`

### Cấu hình Hạ tầng

#### SSH Connection Status
⚠️ **QUAN TRỌNG**: Hiện tại đang SSH vào **translation01** (Manager Node)
- **Node hiện tại**: translation01 (35.185.191.80)
- **Manager Node**: translation01 - ĐANG KẾT NỐI
- **KHÔNG cần SSH lại** khi thực hiện các tác vụ trên translation01
- Docker Swarm commands có thể chạy trực tiếp (đang ở Manager Node)
- SSH đến worker nodes: sử dụng key `~/.ssh/translation_cluster`

#### Chi tiết Instances

**Instance 1: translation01** (Manager Node - ⚠️ ĐANG KẾT NỐI)
- Loại: c2d-highmem-4 (4 vCPUs, 32 GB RAM)
- Disk: 100GB Balanced persistent disk
- Zone: asia-southeast1-a
- External IP: 34.87.0.159 ⚠️ **Updated Dec 02, 2025**
- External IPv6: 2600:1900:4080:470:0:1::
- Internal IP: 10.200.0.5 ⚠️ **Updated Dec 02, 2025**
- Network: VPC 10.200.0.0/24
- Vai trò: **Manager Node** + Core Services (Traefik, Gateway, Frontend)
- Không có GPU
- **Docker Swarm**: Manager node (Leader, 10.200.0.5:2377)
- **⚠️ SSH Status**: ĐANG KẾT NỐI - Không cần SSH lại

**Instance 2: translation02** (Worker Node)
- Loại: c2d-highmem-4 (4 vCPUs, 32 GB Memory)  
- Disk: 100GB SSD persistent disk
- Zone: asia-southeast1-a ⚠️ **Updated Dec 02, 2025** (same zone as translation01)
- External IP: 35.240.181.166 ⚠️ **Updated Dec 02, 2025**
- Internal IP: 10.200.0.6 ⚠️ **Updated Dec 02, 2025**
- Network: VPC 10.200.0.0/24
- Firewall: HTTP, HTTPS, Health check, WebRTC (UDP/TCP 40000-40100)
- Vai trò: Worker Node + AI Services (STT, Translation)
- **Docker Swarm**: Worker node (Active, Ready)
- **SSH từ translation01**: `ssh -i ~/.ssh/translation_cluster hopboy2003@10.200.0.6`

**Instance 3: translation03** (Worker Node)
- Loại: c2d-highmem-4 (4 vCPUs, 32 GB Memory)
- Disk: 50GB SSD persistent disk
- Zone: asia-southeast1-a ⚠️ **Updated Dec 02, 2025** (same zone as all nodes)
- External IP: 34.177.86.87 ⚠️ **Updated Dec 02, 2025**
- Internal IP: 10.200.0.8 ⚠️ **Updated Dec 02, 2025**
- Network: VPC 10.200.0.0/24
- Firewall: HTTP, HTTPS, Health check
- Vai trò: Worker Node + Monitoring (Prometheus, Grafana, TTS)
- **Docker Swarm**: Worker node (Active, Ready)
- **SSH từ translation01**: `ssh -i ~/.ssh/translation_cluster hopboy2003@10.200.0.8`

## Kiến trúc Hệ thống

### Tech Stack
1. **Container Orchestration**: Docker Swarm
2. **WebRTC Gateway**: MediaSoup hoặc Janus Gateway (CPU-optimized)
3. **Speech Recognition**: Whisper (faster-whisper với quantization)
4. **Translation**: NLLB-200 hoặc Opus-MT từ Hugging Face
5. **Voice Cloning**: XTTS v2 hoặc Coqui TTS
6. **Backend**: FastAPI (Python)
7. **Frontend**: React với WebRTC
8. **Message Queue**: Redis
9. **Database**: PostgreSQL
10. **Monitoring**: Prometheus + Grafana
11. **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana) - lightweight version

### Cấu trúc Thư mục
```
jbcalling_translation_realtime/
├── .github/
│   ├── copilot-instructions.md (file này)
│   └── workflows/
├── docs/
│   ├── 01-ARCHITECTURE.md
│   ├── 02-SETUP-GUIDE.md
│   ├── 03-DOCKER-SWARM.md
│   ├── 04-SERVICES.md
│   ├── 05-AI-MODELS.md
│   ├── 06-WEBRTC.md
│   ├── 07-API-REFERENCES.md
│   ├── 08-DEPLOYMENT.md
│   ├── 09-MONITORING.md
│   └── 10-TROUBLESHOOTING.md
├── services/
│   ├── gateway/          # WebRTC gateway service
│   ├── transcription/    # Speech-to-text service
│   ├── translation/      # Translation service
│   ├── voice-cloning/    # Voice synthesis service
│   ├── api/             # Main API service
│   ├── frontend/        # React frontend
│   └── monitoring/      # Monitoring stack
├── shared/
│   ├── models/          # Shared data models
│   ├── utils/           # Shared utilities
│   └── config/          # Shared configurations
├── infrastructure/
│   ├── docker-compose.yml
│   ├── docker-compose.override.yml
│   └── swarm/
│       ├── stack.yml
│       └── configs/
├── scripts/
│   ├── setup/
│   ├── deploy/
│   └── maintenance/
└── tests/
```

## Nguyên tắc Code

### 1. Python Code Style
- Sử dụng PEP 8
- Type hints bắt buộc cho tất cả functions/methods
- Docstrings bằng tiếng Việt cho tất cả public functions/classes
- Async/await cho I/O operations
- Exception handling đầy đủ với logging

```python
from typing import Optional, List
import logging

logger = logging.getLogger(__name__)

async def transcribe_audio(
    audio_data: bytes,
    language: Optional[str] = None
) -> dict:
    """
    Chuyển đổi audio thành text sử dụng Whisper model.
    
    Args:
        audio_data: Dữ liệu audio ở dạng bytes
        language: Ngôn ngữ của audio (optional, auto-detect nếu None)
        
    Returns:
        dict: Kết quả transcription với text, timestamps, và confidence
        
    Raises:
        TranscriptionError: Khi không thể transcribe audio
    """
    try:
        # Implementation
        pass
    except Exception as e:
        logger.error(f"Lỗi khi transcribe audio: {e}")
        raise
```

### 2. Docker Best Practices
- Multi-stage builds để giảm image size
- Non-root user cho security
- Health checks cho tất cả services
- Resource limits (CPU, Memory) rõ ràng
- Secrets management với Docker secrets
- Logging driver chuẩn

### 3. API Design
- RESTful endpoints với versioning (/api/v1/)
- WebSocket cho real-time communication
- Request/Response validation với Pydantic
- Rate limiting
- Authentication với JWT
- API documentation tự động với OpenAPI/Swagger

### 4. Error Handling
- Centralized error handling
- Meaningful error messages (tiếng Việt cho user-facing)
- Error codes chuẩn hóa
- Logging đầy đủ context
- Graceful degradation

### 5. Performance Optimization
- Model quantization (INT8) cho Whisper và Translation
- Batch processing khi có thể
- Caching strategies với Redis
- Connection pooling
- Lazy loading cho models
- CPU optimization (không dùng CUDA)

### 6. Security
- Input validation nghiêm ngặt
- Output sanitization
- Rate limiting per user/IP
- CORS configuration đúng
- Secrets trong environment variables hoặc Docker secrets
- HTTPS only trong production
- WebRTC security (DTLS-SRTP)

## Model AI Guidelines

### 1. Whisper (Speech Recognition)
- Sử dụng `faster-whisper` thay vì `openai-whisper`
- Model size: `base` hoặc `small` (do giới hạn CPU)
- Quantization: INT8
- Batch size: 1-2 (do RAM limit)
- VAD (Voice Activity Detection) để tối ưu

### 2. Translation Models
- NLLB-200-distilled-600M (smaller, faster)
- Opus-MT models cho language pairs cụ thể
- Caching cho câu đã dịch
- Fallback: Google Translate API (free tier)

### 3. Voice Cloning
- XTTS v2 (CPU-compatible)
- Voice sample: 10-30 seconds
- Caching synthesized audio
- Fallback: gTTS cho simple cases

### 4. Speaker Diarization
- PyAnnote.audio hoặc Simple-diarization
- Minimum speaker duration: 1 second
- Maximum speakers: 10

## Testing Guidelines

### 1. Unit Tests
- Coverage tối thiểu: 80%
- Sử dụng pytest
- Mock external services
- Test cả happy path và error cases

### 2. Integration Tests
- Test communication giữa services
- Test Docker Swarm scaling
- Load testing với locust

### 3. E2E Tests
- Test full user flow
- WebRTC connection testing
- Cross-browser testing

## Deployment Guidelines

### 1. Staging Environment
- Replica giảm
- Logging verbose
- Debug mode enabled

### 2. Production Environment
- High availability
- Auto-scaling rules
- Backup strategies
- Monitoring alerts
- Rolling updates

### 3. CI/CD Secrets & Registry

**Container Registry**: Docker Hub (`docker.io/jackboun11/jbcalling-<service>`)
- Đồng bộ với `infrastructure/helm/jbcalling/values.yaml` (`global.imageRegistry: docker.io`).
- KHÔNG dùng `ghcr.io` (đã từng cấu hình nhưng đã chuyển sang Docker Hub).

**GitHub Actions Secrets cần có** (Settings → Secrets and variables → Actions):
| Secret | Mục đích |
|--------|----------|
| `DOCKERHUB_USERNAME` | Username Docker Hub (`jackboun11`) |
| `DOCKERHUB_TOKEN` | Personal Access Token Docker Hub (Read/Write/Delete) |
| `GITHUB_TOKEN` | Tự động sẵn có, dùng cho auto-PR bump tag |

**Quy ước với secret**:
- Token thực tế lưu cục bộ trong `.env` (đã gitignore qua `*.env` và `.env`).
- KHÔNG ghi giá trị token vào bất kỳ file nào trong repo (kể cả docs).
- Khi token bị lộ trong chat/log, **revoke ngay** trên Docker Hub Security và tạo PAT mới.

**Quy trình bump image tag**:
1. Push code lên `main` (paths `services/**`).
2. Workflow `ci-services.yml` build + push image lên Docker Hub với tag `sha-<short-sha>` và `latest`.
3. Workflow tự tạo PR `chore/bump-<service>-<sha>` cập nhật `image.tag` trong `values-prod.yaml`.
4. Review + merge PR → Argo CD `jbcalling-prod` (manual sync) → đồng bộ lên cluster.

## Monitoring & Logging

### 1. Metrics cần track
- Request latency
- Transcription accuracy
- Translation quality (BLEU score)
- CPU/Memory usage per service
- WebRTC connection quality
- Model inference time

### 2. Alerts
- Service down
- High error rate
- Resource exhaustion
- Slow response time

## Documentation Standards

### 1. Code Documentation
- Docstrings tiếng Việt
- Inline comments cho logic phức tạp
- README.md cho mỗi service

### 2. API Documentation
- OpenAPI/Swagger specs
- Example requests/responses
- Error codes documentation

### 3. Deployment Documentation
- Step-by-step guides
- Configuration references
- Troubleshooting guides

## Quy trình Làm việc với Agent

### SSH & Environment Context
⚠️ **QUAN TRỌNG - Trạng thái SSH hiện tại**:
- **Đang kết nối SSH vào**: translation01 (35.185.191.80) - **Manager Node**
- **KHÔNG cần SSH lại** khi làm việc trên translation01
- Docker Swarm commands có thể chạy trực tiếp (đang ở Manager Node)
- **Kiểm tra trước khi SSH**: Luôn xác nhận node hiện tại trước khi thực hiện lệnh SSH
- **SSH đến worker nodes**:
  - `ssh -i ~/.ssh/translation_cluster hopboy2003@10.200.0.6` (translation02)
  - `ssh -i ~/.ssh/translation_cluster hopboy2003@10.200.0.8` (translation03)

#### SSH Command Templates
⚠️ **translation01 đã có IPv6** - Sử dụng gcloud compute ssh thay vì ssh trực tiếp:

**Template chuẩn cho Docker service commands:**
```bash
# Kiểm tra service status
gcloud compute ssh translation01 --zone=asia-southeast1-a --command="docker service ps <SERVICE_NAME> --filter 'desired-state=running' --format 'table {{.Name}}\t{{.Image}}\t{{.CurrentState}}'"

# Xem logs với timestamps
gcloud compute ssh translation01 --zone=asia-southeast1-a --command="docker service logs <SERVICE_NAME> --tail 10 --timestamps"

# Combined: Status + Logs
gcloud compute ssh translation01 --zone=asia-southeast1-a --command="docker service ps <SERVICE_NAME> --filter 'desired-state=running' --format 'table {{.Name}}\t{{.Image}}\t{{.CurrentState}}' && echo '---' && docker service logs <SERVICE_NAME> --tail 10 --timestamps"

# List all services
gcloud compute ssh translation01 --zone=asia-southeast1-a --command="docker service ls"

# Deploy stack
gcloud compute ssh translation01 --zone=asia-southeast1-a --command="docker stack deploy -c /tmp/stack-hybrid.yml translation"

# Service inspect
gcloud compute ssh translation01 --zone=asia-southeast1-a --command="docker service inspect <SERVICE_NAME> --pretty"
```

**Common service names:**
- `translation_gateway` - WebRTC Gateway (MediaSoup)
- `translation_frontend` - React Frontend
- `translation_traefik` - Reverse Proxy
- `translation_redis` - Cache & Message Queue
- `translation_prometheus` - Metrics
- `translation_grafana` - Monitoring Dashboard

### Khi Nhận Yêu cầu Mới:
1. ✅ Đọc kỹ yêu cầu và xác định scope
2. ✅ **ĐỌC TÀI LIỆU HIỆN CÓ** (check DOCUMENTATION-INDEX.md → latest status)
3. ✅ Kiểm tra docs liên quan trong `/docs`
4. ✅ Xác định services bị ảnh hưởng
5. ✅ Kiểm tra xem có cần thông tin thực từ người dùng không
6. ⚠️ Nếu cần thông tin thực: DỪNG và yêu cầu cung cấp
7. ✅ **Kiểm tra file đã tồn tại - ưu tiên update thay vì tạo mới**
8. ✅ Chỉ triển khai sau khi có đầy đủ thông tin
9. ✅ Viết code theo conventions
10. ✅ Test local nếu có thể
11. ✅ Update documentation liên quan (trong file có sẵn)
12. ✅ Commit với message rõ ràng (tiếng Việt)
10. ✅ Update documentation liên quan (trong file có sẵn)
11. ✅ Commit với message rõ ràng (tiếng Việt)

### Khi Debug Issues:
1. Đọc logs từ Grafana/ELK
2. Check metrics trong Prometheus
3. Verify service health
4. Check network connectivity
5. Review recent changes
6. Test in isolation

### Khi Thêm Feature Mới:
1. Tạo branch mới
2. Update architecture docs nếu cần
3. Implement với tests
4. Update API docs
5. Test end-to-end
6. Update deployment configs
7. Merge sau khi review

## Ưu tiên Giải pháp

### 1. Model Selection
- Ưu tiên models nhỏ, nhanh, CPU-optimized
- Có sẵn trên Hugging Face
- Free, open-source
- Community support tốt

### 2. Infrastructure
- Cost-effective
- Scalable
- Observable
- Maintainable

### 3. User Experience
- Low latency (STT <800ms, E2E <1.5s)
- High accuracy (WER <10% hoặc độ chính xác >90%)
- Smooth video/audio
- Clear captions

## Version Control

### Commit Messages (Tiếng Việt)
```
feat: Thêm tính năng voice cloning với XTTS
fix: Sửa lỗi memory leak trong transcription service
docs: Cập nhật hướng dẫn deployment
refactor: Tối ưu hóa translation pipeline
test: Thêm tests cho WebRTC gateway
```

### Branch Naming
```
feature/voice-cloning
bugfix/memory-leak-transcription
hotfix/webrtc-connection
docs/update-deployment-guide
```

## Checklist cho Agent

Trước khi hoàn thành mỗi task, kiểm tra:

- [ ] Code tuân thủ conventions
- [ ] Comments và docstrings bằng tiếng Việt
- [ ] Type hints đầy đủ
- [ ] Error handling đúng cách
- [ ] Logging đầy đủ
- [ ] Tests đã viết và pass
- [ ] Documentation đã update
- [ ] Docker configs đã update (nếu cần)
- [ ] Không có hardcoded secrets
- [ ] Resource limits đã set
- [ ] Health checks đã thêm
- [ ] ⚠️ Đã yêu cầu người dùng cung cấp thông tin thực (nếu cần)
- [ ] ⚠️ Không có placeholder/mock data trong production code
- [ ] ⚠️ Đã cân nhắc update file có sẵn thay vì tạo file mới
- [ ] ⚠️ Không tạo file documentation trùng lặp hoặc không cần thiết

## Documentation Kế Thừa & Cập Nhật

### Quy tắc Đọc Documentation
1. **LUÔN check DOCUMENTATION-INDEX.md trước**
   - File này là single source of truth cho documentation structure
   - Liệt kê tất cả docs theo priority
   - Chỉ dẫn đọc theo task

2. **Đọc theo thứ tự Priority**:
   - Priority 1 (URGENT): System status, investigations, wrap-ups
   - Priority 2 (Context): ROADMAP, README
   - Priority 3 (Technical): docs/ folder
   - Priority 4 (Historical): Old reports (reference only)

3. **Identify Latest Status**:
   - Format: `SYSTEM-STATUS-OCT<DD>-2025.md`
   - Latest = highest DD (date number)
   - Check superseded notices trong old files

### Quy tắc Update Documentation

#### Khi Update Status Reports:
```
1. Đọc latest SYSTEM-STATUS-OCT*.md
2. Tạo NEW file với date mới (nếu major changes)
   Format: SYSTEM-STATUS-OCT<DD>-2025.md
3. Add superseded notice vào file cũ
4. Update DOCUMENTATION-INDEX.md
5. Update README.md banner nếu critical
```

#### Khi Kết Thúc Session:
```
1. Tạo WRAP-UP-OCT<DD>.md với:
   - Achievements summary
   - Current state
   - Next steps (chi tiết)
   - Time estimates
2. Update ROADMAP-UPDATED-OCT2025.md progress
3. Tạo COMMIT-MESSAGE-OCT<DD>-<TOPIC>.txt
4. Update DOCUMENTATION-INDEX.md nếu có file mới
```

#### Khi Investigation/Troubleshooting:
```
1. Tạo <TOPIC>-INVESTIGATION-OCT<DD>.md với:
   - Problem statement
   - Approaches tried (with results)
   - Research findings
   - Recommended solutions
2. Link từ WRAP-UP-OCT<DD>.md
3. Add vào DOCUMENTATION-INDEX.md section "Recent Reports"
```

### Documentation Structure Standards

#### File Headers (Required):
```markdown
# Title

**Date**: October DD, 2025
**Status**: [Active|Superseded|Historical]
**Phase**: Phase X-Y
**Related**: [Links to other docs]

---

## Executive Summary
[3-5 sentences overview]
```

#### Superseded Notices (When creating new version):
```markdown
> ⚠️ Superseded Notice (2025-10-DD)
> This document has been superseded by [NEW-FILE.md].
> Key changes: [Brief description]
> Use this file only as historical reference.
```

#### Status Indicators (Consistent usage):
```
✅ Complete/Working
⚠️ Partial/Warning
❌ Failed/Not Working
⏸️ Pending/Blocked
🔴 Critical/Urgent
🎯 Action Required
📊 Metrics/Data
🚀 Deployment/Release
🔬 Investigation/Research
```

### File Retention Policy

**Keep**:
- Latest system status (current month)
- Investigation reports (technical reference)
- Wrap-up files (session history)
- ROADMAP (monthly update)

**Archive** (move to `archive/` folder):
- System status >1 month old
- Superseded reports
- Old commit messages
- Temporary analysis files

**Delete**:
- Duplicate documentation
- Unfinished drafts after completion
- Test/scratch files

### Quick Reference Checklist

Khi bắt đầu làm việc:
- [ ] Check DOCUMENTATION-INDEX.md
- [ ] Read latest SYSTEM-STATUS-OCT*.md
- [ ] Check ROADMAP phase hiện tại
- [ ] Read relevant investigation reports
- [ ] Understand current blockers

Khi kết thúc làm việc:
- [ ] Create/Update WRAP-UP-OCT<DD>.md
- [ ] Update ROADMAP progress
- [ ] Update README.md if needed
- [ ] Create SYSTEM-STATUS-OCT<DD>.md if major changes
- [ ] Update DOCUMENTATION-INDEX.md
- [ ] Create COMMIT-MESSAGE-OCT<DD>-<TOPIC>.txt

## Liên hệ & Support

Khi gặp vấn đề không thể tự giải quyết:
1. Document vấn đề chi tiết
2. Thu thập logs và metrics
3. Tạo issue với đầy đủ context
4. Tag với labels phù hợp

---

**LƯU Ý QUAN TRỌNG**: Agent PHẢI tuân thủ các nguyên tắc trên, đặc biệt là việc phản hồi tiếng Việt và YÊU CẦU THÔNG TIN THỰC trước khi tiếp tục. Không được tự ý bỏ qua hoặc tự điền thông tin giả.
