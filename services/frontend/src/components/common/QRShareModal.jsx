import { useState } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { X, Copy, Check } from 'lucide-react';

/**
 * QRShareModal - Hiển thị QR code chứa URL join room.
 * Người khác scan QR sẽ được điều hướng tới `/?join={roomId}`,
 * Home page tự prefill mã phòng và chuyển sang form Join.
 */
export default function QRShareModal({ roomId, onClose }) {
  const [copied, setCopied] = useState(false);

  // URL chứa query param join để Home page tự xử lý
  const origin = typeof window !== 'undefined' ? window.location.origin : 'https://jbcalling.site';
  const joinUrl = `${origin}/?join=${encodeURIComponent(roomId)}`;

  const handleCopyUrl = async () => {
    try {
      await navigator.clipboard.writeText(joinUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      console.error('Clipboard error:', err);
    }
  };

  return (
    <div
      className="qr-modal-backdrop"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="qr-share-title"
    >
      <div className="qr-modal" onClick={(e) => e.stopPropagation()}>
        <button
          type="button"
          className="qr-modal__close"
          onClick={onClose}
          aria-label="Đóng"
        >
          <X size={20} />
        </button>

        <h2 id="qr-share-title" className="qr-modal__title">
          Chia sẻ phòng
        </h2>
        <p className="qr-modal__subtitle">
          Người khác có thể quét mã QR bằng camera để tham gia ngay
        </p>

        <div className="qr-modal__code">
          <QRCodeSVG
            value={joinUrl}
            size={240}
            level="M"
            includeMargin
            bgColor="#ffffff"
            fgColor="#0f172a"
          />
        </div>

        <div className="qr-modal__roomid">
          <span className="qr-modal__label">Mã phòng</span>
          <code className="qr-modal__roomid-value">{roomId}</code>
        </div>

        <button
          type="button"
          className="qr-modal__copy-btn"
          onClick={handleCopyUrl}
        >
          {copied ? (
            <>
              <Check size={18} /> Đã sao chép link
            </>
          ) : (
            <>
              <Copy size={18} /> Sao chép link mời
            </>
          )}
        </button>
      </div>
    </div>
  );
}
