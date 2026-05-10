import { useState, useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { useWebRTC } from '../contexts/WebRTCContext'
import { 
  Video, 
  Languages, 
  MessageSquare, 
  Monitor, 
  Mic,
  Sparkles,
  Info,
  ScanLine
} from 'lucide-react'
import Logo from '../assets/JBCalling_Web_NoBg.svg'
import QRScanner from '../components/common/QRScanner'

export default function Home() {
  const navigate = useNavigate()
  const [searchParams, setSearchParams] = useSearchParams()
  const { createRoom } = useWebRTC()
  const [username, setUsername] = useState('')
  const [roomCode, setRoomCode] = useState('')
  const [isJoining, setIsJoining] = useState(false)
  const [isCreating, setIsCreating] = useState(false)
  const [showScanner, setShowScanner] = useState(false)

  // Khi mở Home với query ?join=room_xxx (do người khác scan QR share),
  // tự prefill mã phòng và chuyển sang form Join.
  useEffect(() => {
    const joinId = searchParams.get('join')
    if (joinId) {
      setRoomCode(joinId)
      setIsJoining(true)
      const savedName = localStorage.getItem('jb_username') || ''
      if (savedName) setUsername(savedName)
      // Xoá query param khỏi URL cho gọn
      const next = new URLSearchParams(searchParams)
      next.delete('join')
      setSearchParams(next, { replace: true })
    }
  }, [])

  const handleCreateRoom = async (e) => {
    e.preventDefault()
    if (!username.trim()) {
      alert('Vui lòng nhập tên của bạn')
      return
    }

    try {
      setIsCreating(true)
      
      // Lưu username vào localStorage
      localStorage.setItem('jb_username', username.trim())
      
      // Gọi Gateway API để tạo room thật
      const newRoomId = await createRoom()
      
      // Navigate đến room với roomId từ Gateway
      navigate(`/room/${newRoomId}`)
    } catch (error) {
      console.error('❌ Error creating room:', error)
      alert('Không thể tạo phòng. Vui lòng thử lại.')
      setIsCreating(false)
    }
  }

  const handleJoinRoom = (e) => {
    e.preventDefault()
    if (!username.trim()) {
      alert('Vui lòng nhập tên của bạn')
      return
    }
    if (!roomCode.trim()) {
      alert('Vui lòng nhập mã phòng')
      return
    }

    // Lưu username vào localStorage
    localStorage.setItem('jb_username', username.trim())
    
    // Navigate đến room (giữ nguyên case của room ID)
    navigate(`/room/${roomCode.trim()}`)
  }

  const handleScanSuccess = ({ roomId, username: scannedUsername }) => {
    localStorage.setItem('jb_username', scannedUsername)
    setShowScanner(false)
    navigate(`/room/${roomId}`)
  }

  return (
    <div className="home-container">
      <div className="home-header">
        <img src={Logo} alt="JB Calling" className="home-logo" />
        <p className="home-tagline">Hệ thống video call với dịch thuật real-time</p>
      </div>

      <div className="join-room-section">
        {!isJoining ? (
          // Create Room Form
          <form onSubmit={handleCreateRoom}>
            <h2>Tạo Phòng Mới</h2>
            
            <div className="form-group">
              <label htmlFor="username">Tên của bạn</label>
              <input
                type="text"
                id="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Nhập tên của bạn"
                required
                autoFocus
              />
            </div>

            <button type="submit" className="btn-primary" disabled={isCreating}>
              {isCreating ? 'Đang tạo phòng...' : 'Tạo Phòng & Nhận Mã'}
            </button>

            <button 
              type="button"
              onClick={() => setIsJoining(true)}
              className="btn-link"
              disabled={isCreating}
            >
              Đã có mã phòng? Tham gia ngay
            </button>

            <button
              type="button"
              onClick={() => setShowScanner(true)}
              className="home-scan-btn"
              disabled={isCreating}
            >
              <ScanLine size={18} />
              Quét mã QR để tham gia
            </button>
          </form>
        ) : (
          // Join Room Form
          <form onSubmit={handleJoinRoom}>
            <h2>Tham Gia Phòng</h2>
            
            <div className="form-group">
              <label htmlFor="username-join">Tên của bạn</label>
              <input
                type="text"
                id="username-join"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Nhập tên của bạn"
                required
                autoFocus
              />
            </div>

            <div className="form-group">
              <label htmlFor="roomCode">Mã phòng</label>
              <input
                type="text"
                id="roomCode"
                value={roomCode}
                onChange={(e) => setRoomCode(e.target.value)}
                placeholder="room_1234567890_abc12xyz"
                required
                maxLength="50"
              />
            </div>

            <button type="submit" className="btn-primary">
              Tham Gia Phòng
            </button>

            <button 
              type="button"
              onClick={() => setIsJoining(false)}
              className="btn-link"
            >
              Quay lại tạo phòng mới
            </button>

            <button
              type="button"
              onClick={() => setShowScanner(true)}
              className="home-scan-btn"
            >
              <ScanLine size={18} />
              Quét mã QR để tham gia
            </button>
          </form>
        )}

        {showScanner && (
          <QRScanner
            defaultUsername={username}
            onClose={() => setShowScanner(false)}
            onSubmit={handleScanSuccess}
          />
        )}

        <div className="feature-card">
          <h3>
            <Sparkles className="icon-sparkle" size={24} strokeWidth={2.5} />
            Tính năng
          </h3>
          <ul>
            <li>
              <Video size={20} strokeWidth={2} className="feature-icon" />
              Video call chất lượng cao với WebRTC
            </li>
            <li>
              <Languages size={20} strokeWidth={2} className="feature-icon" />
              Dịch thuật tự động real-time
            </li>
            <li>
              <MessageSquare size={20} strokeWidth={2} className="feature-icon" />
              Hỗ trợ đa ngôn ngữ (Việt, Anh, ...)
            </li>
            <li>
              <MessageSquare size={20} strokeWidth={2} className="feature-icon" />
              Chat trong cuộc gọi
            </li>
            <li>
              <Monitor size={20} strokeWidth={2} className="feature-icon" />
              Screen sharing
            </li>
            <li className="feature-upcoming">
              <Mic size={20} strokeWidth={2} className="feature-icon feature-icon-upcoming" />
              Voice cloning (đang phát triển)
            </li>
          </ul>

          <div className="feature-note">
            <Info size={18} className="note-icon" />
            <p>
              <strong>Lưu ý:</strong> Không cần đăng ký tài khoản. 
              Chỉ cần tên và mã phòng để bắt đầu!
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
