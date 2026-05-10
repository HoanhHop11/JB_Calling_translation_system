import { useEffect, useRef, useState } from 'react';
import { Html5Qrcode } from 'html5-qrcode';
import { X, Camera, AlertCircle } from 'lucide-react';

/**
 * Trích room ID từ URL hoặc trả về raw text.
 * Hỗ trợ:
 *   - https://jbcalling.site/?join=room_xxx
 *   - https://jbcalling.site/room/room_xxx
 *   - room_xxx (raw)
 */
function extractRoomId(scannedText) {
  if (!scannedText) return null;
  try {
    const url = new URL(scannedText);
    const fromQuery = url.searchParams.get('join');
    if (fromQuery) return fromQuery;
    const match = url.pathname.match(/\/room\/([^/?#]+)/);
    if (match) return match[1];
    return null;
  } catch {
    // Không phải URL hợp lệ -> coi là raw room ID nếu khớp pattern
    if (/^room_[a-zA-Z0-9_-]+$/.test(scannedText.trim())) {
      return scannedText.trim();
    }
    return null;
  }
}

/**
 * QRScanner - Modal camera scan QR.
 *  Bước 1: scan QR -> nhận roomId
 *  Bước 2: nhập tên -> gọi onSubmit({ roomId, username })
 */
export default function QRScanner({ onSubmit, onClose, defaultUsername = '' }) {
  const containerId = 'qr-scanner-region';
  const scannerRef = useRef(null);

  const [stage, setStage] = useState('scanning'); // 'scanning' | 'enter-name'
  const [scannedRoomId, setScannedRoomId] = useState('');
  const [username, setUsername] = useState(defaultUsername);
  const [error, setError] = useState('');

  // Khởi tạo và dọn dẹp scanner mỗi khi vào/ra giai đoạn scanning
  useEffect(() => {
    if (stage !== 'scanning') return;

    let isMounted = true;
    setError('');

    const startScanner = async () => {
      try {
        const html5QrCode = new Html5Qrcode(containerId);
        scannerRef.current = html5QrCode;

        await html5QrCode.start(
          { facingMode: 'environment' },
          {
            fps: 10,
            qrbox: { width: 240, height: 240 },
            aspectRatio: 1.0,
          },
          (decodedText) => {
            const roomId = extractRoomId(decodedText);
            if (roomId && isMounted) {
              setScannedRoomId(roomId);
              setStage('enter-name');
              html5QrCode.stop().catch(() => {});
            }
          },
          () => {
            // Bỏ qua lỗi scan từng frame (bình thường, không hiển thị)
          }
        );
      } catch (err) {
        console.error('Camera error:', err);
        if (isMounted) {
          setError(
            'Không thể truy cập camera. Vui lòng cấp quyền camera hoặc nhập mã phòng thủ công.'
          );
        }
      }
    };

    startScanner();

    return () => {
      isMounted = false;
      const inst = scannerRef.current;
      if (inst) {
        inst
          .stop()
          .then(() => inst.clear())
          .catch(() => {});
        scannerRef.current = null;
      }
    };
  }, [stage]);

  const handleConfirmJoin = (e) => {
    e.preventDefault();
    const trimmedName = username.trim();
    if (!trimmedName) {
      setError('Vui lòng nhập tên của bạn');
      return;
    }
    if (!scannedRoomId) {
      setError('Mã phòng không hợp lệ. Vui lòng thử lại.');
      return;
    }
    onSubmit({ roomId: scannedRoomId, username: trimmedName });
  };

  return (
    <div
      className="qr-modal-backdrop"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="qr-scan-title"
    >
      <div className="qr-modal qr-modal--scanner" onClick={(e) => e.stopPropagation()}>
        <button
          type="button"
          className="qr-modal__close"
          onClick={onClose}
          aria-label="Đóng"
        >
          <X size={20} />
        </button>

        {stage === 'scanning' && (
          <>
            <h2 id="qr-scan-title" className="qr-modal__title">
              <Camera size={22} style={{ marginRight: 8, verticalAlign: 'middle' }} />
              Quét mã QR để tham gia
            </h2>
            <p className="qr-modal__subtitle">
              Hướng camera vào mã QR của phòng
            </p>

            <div id={containerId} className="qr-scanner__region" />

            {error && (
              <div className="qr-modal__error">
                <AlertCircle size={16} /> {error}
              </div>
            )}
          </>
        )}

        {stage === 'enter-name' && (
          <form onSubmit={handleConfirmJoin}>
            <h2 className="qr-modal__title">Nhập tên để tham gia</h2>
            <p className="qr-modal__subtitle">
              Phòng: <code className="qr-modal__roomid-inline">{scannedRoomId}</code>
            </p>

            <div className="form-group">
              <label htmlFor="qr-username">Tên của bạn</label>
              <input
                id="qr-username"
                type="text"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                placeholder="Nhập tên của bạn"
                autoFocus
                required
              />
            </div>

            {error && (
              <div className="qr-modal__error">
                <AlertCircle size={16} /> {error}
              </div>
            )}

            <div className="qr-modal__actions">
              <button
                type="button"
                className="btn-link"
                onClick={() => {
                  setStage('scanning');
                  setScannedRoomId('');
                  setError('');
                }}
              >
                Quét lại
              </button>
              <button type="submit" className="btn-primary">
                Tham gia phòng
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}
