import { useEffect, useMemo, useState } from 'react';
import {
  NavLink,
  Navigate,
  Outlet,
  Route,
  Routes,
  useNavigate,
  useOutletContext,
  useParams
} from 'react-router-dom';
import {
  API_BASE_URL,
  fetchAdminReviewDetail,
  fetchAdminSiteDetail,
  fetchAdminStats,
  fetchPendingReviews,
  fetchPendingSites,
  fetchUsers,
  getStoredToken,
  getStoredUser,
  isAdminRole,
  login,
  logout,
  moderateReview,
  moderateSite,
  updateUserStatus
} from './lib/api.js';

const DASHBOARD_HOME = '/dashboard/overview';

const siteModerationActions = [
  { value: 'APPROVE', label: 'Approuver' },
  { value: 'REJECT', label: 'Rejeter' },
  { value: 'ARCHIVE', label: 'Archiver' }
];

const reviewModerationActions = [
  { value: 'APPROVE', label: 'Publier' },
  { value: 'REJECT', label: 'Rejeter' },
  { value: 'FLAG', label: 'Masquer / signaler' },
  { value: 'SPAM', label: 'Marquer comme spam' }
];

const userStatusOptions = [
  { value: 'ACTIVE', label: 'Actif' },
  { value: 'SUSPENDED', label: 'Suspendu' },
  { value: 'INACTIVE', label: 'Inactif' }
];

const userRoleOptions = [
  { value: '', label: 'Tous les roles' },
  { value: 'ADMIN', label: 'ADMIN' },
  { value: 'MODERATOR', label: 'MODERATOR' },
  { value: 'PROFESSIONAL', label: 'PROFESSIONAL' },
  { value: 'CONTRIBUTOR', label: 'CONTRIBUTOR' },
  { value: 'TOURIST', label: 'TOURIST' }
];

const userStatusFilters = [
  { value: '', label: 'Tous les statuts' },
  { value: 'ACTIVE', label: 'Actifs' },
  { value: 'SUSPENDED', label: 'Suspendus' },
  { value: 'INACTIVE', label: 'Inactifs' }
];

function App() {
  const [session, setSession] = useState(() => ({
    token: getStoredToken(),
    user: getStoredUser()
  }));
  const [bootError, setBootError] = useState('');

  const isAuthorized = useMemo(
    () => Boolean(session.token) && isAdminRole(session.user?.role),
    [session]
  );

  useEffect(() => {
    if (session.token && session.user && !isAdminRole(session.user.role)) {
      setBootError(
        'Ce compte est connecte mais ne dispose pas des droits admin/moderator.'
      );
    } else {
      setBootError('');
    }
  }, [session]);

  const handleLoggedIn = (nextSession) => {
    setSession(nextSession);
    setBootError('');
  };

  const handleLoggedOut = async () => {
    await logout();
    setSession({ token: null, user: null });
  };

  return (
    <Routes>
      <Route
        path="/login"
        element={
          isAuthorized ? (
            <Navigate to={DASHBOARD_HOME} replace />
          ) : (
            <div className="app-shell">
              <AdminLoginPage
                bootError={bootError}
                onLoggedIn={handleLoggedIn}
              />
            </div>
          )
        }
      />
      <Route
        path="/dashboard"
        element={
          isAuthorized ? (
            <DashboardLayout user={session.user} onLogout={handleLoggedOut} />
          ) : (
            <Navigate to="/login" replace />
          )
        }
      >
        <Route index element={<Navigate to="overview" replace />} />
        <Route path="overview" element={<OverviewPage />} />
        <Route path="sites" element={<SitesPage />} />
        <Route path="sites/:siteId" element={<SiteDetailPage />} />
        <Route path="reviews" element={<ReviewsPage />} />
        <Route path="reviews/:reviewId" element={<ReviewDetailPage />} />
        <Route path="users" element={<UsersPage />} />
        <Route path="users/:userId" element={<UsersPage />} />
      </Route>
      <Route
        path="*"
        element={
          <Navigate to={isAuthorized ? DASHBOARD_HOME : '/login'} replace />
        }
      />
    </Routes>
  );
}

function AdminLoginPage({ onLoggedIn, bootError }) {
  const [email, setEmail] = useState('admin@moroccocheck.com');
  const [password, setPassword] = useState('password123');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (event) => {
    event.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      const session = await login(email.trim(), password);
      if (!isAdminRole(session.user?.role)) {
        throw new Error(
          'Ce compte existe mais ne possede pas un role admin ou moderator.'
        );
      }
      onLoggedIn(session);
    } catch (err) {
      setError(err.message || 'Connexion impossible.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="login-layout">
      <section className="login-hero">
        <p className="eyebrow">MoroccoCheck Admin</p>
        <h1>Web app admin pour la moderation et le pilotage</h1>
        <p className="hero-copy">
          Interface web separee pour les comptes <code>ADMIN</code> et
          <code> MODERATOR</code>, branchee directement sur le backend
          MoroccoCheck.
        </p>
        <dl className="hero-meta">
          <div>
            <dt>API</dt>
            <dd>{API_BASE_URL}</dd>
          </div>
          <div>
            <dt>Fonctions</dt>
            <dd>Stats, moderation, utilisateurs, suivi des files d attente</dd>
          </div>
        </dl>
      </section>
      <section className="login-card-wrap">
        <form className="login-card" onSubmit={handleSubmit}>
          <div>
            <p className="eyebrow muted">Connexion securisee</p>
            <h2>Entrer dans le dashboard</h2>
            <p className="muted-copy">
              Utilise un compte <code>ADMIN</code> ou <code>MODERATOR</code>.
            </p>
          </div>
          <label className="field">
            <span>Email</span>
            <input
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              required
            />
          </label>
          <label className="field">
            <span>Mot de passe</span>
            <input
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
            />
          </label>
          {(bootError || error) && (
            <div className="alert error">{bootError || error}</div>
          )}
          <button type="submit" className="primary-button" disabled={isLoading}>
            {isLoading ? 'Connexion...' : 'Se connecter'}
          </button>
        </form>
      </section>
    </main>
  );
}

function DashboardLayout({ onLogout, user }) {
  const [stats, setStats] = useState(null);
  const [pendingSites, setPendingSites] = useState([]);
  const [pendingReviews, setPendingReviews] = useState([]);
  const [users, setUsers] = useState([]);
  const [sitePagination, setSitePagination] = useState({ page: 1, limit: 5, total: 0 });
  const [reviewPagination, setReviewPagination] = useState({
    page: 1,
    limit: 5,
    total: 0
  });
  const [userPagination, setUserPagination] = useState({ page: 1, limit: 10, total: 0 });
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');
  const [userFilters, setUserFilters] = useState({
    q: '',
    role: '',
    status: ''
  });
  const isAdmin = user?.role === 'ADMIN';

  const loadDashboard = async () => {
    setIsLoading(true);
    setError('');
    try {
      const [statsData, pendingSitesData, pendingReviewsData, usersData] =
        await Promise.all([
          fetchAdminStats(),
          fetchPendingSites({
            page: sitePagination.page,
            limit: sitePagination.limit
          }),
          fetchPendingReviews({
            page: reviewPagination.page,
            limit: reviewPagination.limit
          }),
          fetchUsers({
            ...userFilters,
            page: userPagination.page,
            limit: userPagination.limit
          })
        ]);

      setStats(statsData);
      setPendingSites(pendingSitesData.items);
      setPendingReviews(pendingReviewsData.items);
      setUsers(usersData?.items || []);
      setSitePagination((current) => ({
        ...current,
        ...pendingSitesData.meta
      }));
      setReviewPagination((current) => ({
        ...current,
        ...pendingReviewsData.meta
      }));
      setUserPagination((current) => ({
        ...current,
        ...usersData.meta
      }));
    } catch (err) {
      setError(err.message || 'Impossible de charger le dashboard admin.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadDashboard();
  }, [
    sitePagination.page,
    sitePagination.limit,
    reviewPagination.page,
    reviewPagination.limit,
    userPagination.page,
    userPagination.limit,
    userFilters.q,
    userFilters.role,
    userFilters.status
  ]);

  return (
    <div className="dashboard-layout">
      <header className="topbar">
        <div>
          <p className="eyebrow">Dashboard admin</p>
          <h1>MoroccoCheck Control Room</h1>
          <p className="topbar-copy">
            Connecte en tant que {user?.first_name} {user?.last_name}
            <span className="role-pill">{user?.role}</span>
          </p>
        </div>
        <div className="topbar-actions">
          <button className="ghost-button" onClick={loadDashboard}>
            Actualiser
          </button>
          <button className="ghost-button danger" onClick={onLogout}>
            Deconnexion
          </button>
        </div>
      </header>

      <DashboardTabs />

      {error && <div className="alert error">{error}</div>}

      <section className="stats-grid">
        <StatCard
          label="Utilisateurs"
          value={stats?.users}
          tone="blue"
          isLoading={isLoading}
        />
        <StatCard label="Sites" value={stats?.sites} tone="green" isLoading={isLoading} />
        <StatCard
          label="Sites en attente"
          value={stats?.pending_sites}
          tone="orange"
          isLoading={isLoading}
        />
        <StatCard
          label="Avis en attente"
          value={stats?.pending_reviews}
          tone="sand"
          isLoading={isLoading}
        />
      </section>

      <Outlet
        context={{
          isAdmin,
          isLoading,
          loadDashboard,
          pendingReviews,
          pendingSites,
          reviewPagination,
          setReviewPagination,
          setSitePagination,
          setUserPagination,
          sitePagination,
          stats,
          userFilters,
          userPagination,
          users,
          setUserFilters
        }}
      />
    </div>
  );
}

function DashboardTabs() {
  return (
    <nav className="dashboard-tabs" aria-label="Navigation admin">
      <NavLink className={({ isActive }) => tabClassName(isActive)} to="/dashboard/overview">
        Vue d ensemble
      </NavLink>
      <NavLink className={({ isActive }) => tabClassName(isActive)} to="/dashboard/sites">
        Sites
      </NavLink>
      <NavLink className={({ isActive }) => tabClassName(isActive)} to="/dashboard/reviews">
        Avis
      </NavLink>
      <NavLink className={({ isActive }) => tabClassName(isActive)} to="/dashboard/users">
        Utilisateurs
      </NavLink>
    </nav>
  );
}

function OverviewPage() {
  const { isAdmin, isLoading, pendingReviews, pendingSites, stats, users } =
    useAdminContext();
  const navigate = useNavigate();
  const featuredUser = users[0] || null;

  return (
    <section className="overview-grid">
      <div className="panel">
        <SectionHeader
          eyebrow="Resume"
          title="Files de moderation"
          copy="Vue rapide pour prioriser les actions du jour avant d entrer dans les ecrans specialises."
        />
        <div className="summary-grid">
          <SummaryActionCard
            label="Sites a traiter"
            value={isLoading ? '...' : stats?.pending_sites ?? pendingSites.length}
            helper="Demandes de publication ou de verification"
            onOpen={() => navigate('/dashboard/sites')}
          />
          <SummaryActionCard
            label="Avis a moderer"
            value={isLoading ? '...' : stats?.pending_reviews ?? pendingReviews.length}
            helper="Contributions de la communaute en attente"
            onOpen={() => navigate('/dashboard/reviews')}
          />
          <SummaryActionCard
            label="Comptes a surveiller"
            value={isLoading ? '...' : stats?.suspended_users ?? 0}
            helper="Utilisateurs deja suspendus ou a verifier"
            onOpen={() => navigate('/dashboard/users')}
          />
        </div>
      </div>
      <div className="panel">
        <SectionHeader
          eyebrow="Pilotage"
          title="Contexte du lot"
          copy="La web app couvre maintenant les trois zones critiques: sites, avis et comptes utilisateurs."
        />
        <ul className="feature-list">
          <li>Connexion reelle ADMIN ou MODERATOR</li>
          <li>Routes URL dediees pour chaque espace du dashboard</li>
          <li>Moderation des sites avec note persistante</li>
          <li>Moderation des avis en attente</li>
          <li>Detail utilisateur restorable via URL</li>
        </ul>
      </div>
      <div className="panel">
        <SectionHeader
          eyebrow="Focus"
          title="Utilisateur mis en avant"
          copy="Mini synthese pour garder un contexte humain pendant la gestion des comptes."
        />
        <UserDetailCompact user={featuredUser} />
      </div>
      <div className="panel">
        <SectionHeader
          eyebrow="Etat global"
          title="Vue d ensemble"
          copy="Ce bloc aide a verifier rapidement si la plateforme reste active et saine."
        />
        <dl className="kpi-list">
          <div>
            <dt>Total utilisateurs</dt>
            <dd>{isLoading ? '...' : stats?.users ?? 0}</dd>
          </div>
          <div>
            <dt>Total sites</dt>
            <dd>{isLoading ? '...' : stats?.sites ?? 0}</dd>
          </div>
          <div>
            <dt>Total reviews</dt>
            <dd>{isLoading ? '...' : stats?.reviews ?? 0}</dd>
          </div>
          <div>
            <dt>Total check-ins</dt>
            <dd>{isLoading ? '...' : stats?.checkins ?? 0}</dd>
          </div>
          <div>
            <dt>Acces utilisateur</dt>
            <dd>{isAdmin ? 'Edition complete' : 'Consultation + moderation'}</dd>
          </div>
          <div>
            <dt>Liste comptes chargee</dt>
            <dd>{isLoading ? '...' : users.length}</dd>
          </div>
        </dl>
      </div>
    </section>
  );
}

function SitesPage() {
  const {
    isLoading,
    loadDashboard,
    pendingSites,
    setSitePagination,
    sitePagination
  } = useAdminContext();

  return (
    <section className="panel">
      <SectionHeader
        eyebrow="Moderation sites"
        title="Sites en attente"
        count={pendingSites.length}
        copy="Validation ou rejet d un lieu avec note persistante visible ensuite cote professionnel."
      />
      <PendingSitesList
        items={pendingSites}
        isLoading={isLoading}
        onModerated={loadDashboard}
      />
      <PaginationControls
        pagination={sitePagination}
        onPageChange={(page) =>
          setSitePagination((current) => ({ ...current, page }))
        }
        onLimitChange={(limit) =>
          setSitePagination((current) => ({ ...current, page: 1, limit }))
        }
      />
    </section>
  );
}

function SiteDetailPage() {
  const { siteId } = useParams();
  const { loadDashboard } = useAdminContext();
  const navigate = useNavigate();
  const [site, setSite] = useState(null);
  const [isLoadingDetail, setIsLoadingDetail] = useState(true);
  const [error, setError] = useState('');
  const [action, setAction] = useState('APPROVE');
  const [notes, setNotes] = useState('');
  const [feedback, setFeedback] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadDetail = async () => {
    setIsLoadingDetail(true);
    setError('');
    try {
      const detail = await fetchAdminSiteDetail(siteId);
      setSite(detail);
      setNotes(detail.moderation_notes || '');
    } catch (err) {
      setError(err.message || 'Impossible de charger la fiche site.');
    } finally {
      setIsLoadingDetail(false);
    }
  };

  useEffect(() => {
    loadDetail();
  }, [siteId]);

  const handleModeration = async () => {
    setIsSubmitting(true);
    setFeedback('');
    try {
      await moderateSite(siteId, action, notes);
      setFeedback('Decision de moderation enregistree.');
      await Promise.all([loadDetail(), loadDashboard()]);
    } catch (err) {
      setFeedback(err.message || 'Moderation impossible.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <section className="detail-page">
      <div className="detail-toolbar">
        <button
          type="button"
          className="ghost-button compact"
          onClick={() => navigate('/dashboard/sites')}
        >
          Retour aux sites
        </button>
      </div>
      {isLoadingDetail ? (
        <div className="panel empty-state">Chargement de la fiche site...</div>
      ) : error ? (
        <div className="panel alert error">{error}</div>
      ) : (
        <div className="detail-grid">
          <article className="panel">
            <SectionHeader
              eyebrow="Detail site"
              title={site?.name || 'Site'}
              badge={site?.verification_status || 'PENDING'}
              copy={`${site?.city || 'Ville inconnue'}${site?.region ? `, ${site.region}` : ''}`}
            />
            <dl className="kpi-list">
              <div>
                <dt>Categorie</dt>
                <dd>{site?.category_name || 'Non renseignee'}</dd>
              </div>
              <div>
                <dt>Statut publication</dt>
                <dd>{site?.status || 'Inconnu'}</dd>
              </div>
              <div>
                <dt>Adresse</dt>
                <dd>{site?.address || 'Non renseignee'}</dd>
              </div>
              <div>
                <dt>Contact</dt>
                <dd>{site?.phone_number || site?.email || 'Non renseigne'}</dd>
              </div>
              <div>
                <dt>Note moyenne</dt>
                <dd>{formatRating(site?.average_rating)}</dd>
              </div>
              <div>
                <dt>Total avis</dt>
                <dd>{site?.total_reviews ?? 0}</dd>
              </div>
              <div>
                <dt>Fraicheur</dt>
                <dd>
                  {site?.freshness_score ?? 0} / 100 · {site?.freshness_status || 'N/A'}
                </dd>
              </div>
              <div>
                <dt>Derniere verification</dt>
                <dd>{formatDateTime(site?.last_verified_at)}</dd>
              </div>
            </dl>
            <div className="detail-block">
              <p className="eyebrow muted">Description</p>
              <p>{site?.description || 'Aucune description soumise.'}</p>
            </div>
          </article>

          <article className="panel">
            <SectionHeader
              eyebrow="Soumission"
              title="Contexte proprietaire"
              copy="Informations utiles pour juger la publication ou demander une correction."
            />
            <dl className="kpi-list">
              <div>
                <dt>Proprietaire</dt>
                <dd>
                  {site?.owner_first_name || ''} {site?.owner_last_name || ''}
                </dd>
              </div>
              <div>
                <dt>Email proprietaire</dt>
                <dd>{site?.owner_email || 'Non renseigne'}</dd>
              </div>
              <div>
                <dt>Coordonnees GPS</dt>
                <dd>
                  {site?.latitude}, {site?.longitude}
                </dd>
              </div>
              <div>
                <dt>URL</dt>
                <dd>{site?.website || 'Aucune'}</dd>
              </div>
              <div>
                <dt>Cree le</dt>
                <dd>{formatDateTime(site?.created_at)}</dd>
              </div>
              <div>
                <dt>Mis a jour le</dt>
                <dd>{formatDateTime(site?.updated_at)}</dd>
              </div>
              <div>
                <dt>Derniere moderation</dt>
                <dd>{formatDateTime(site?.moderated_at)}</dd>
              </div>
              <div>
                <dt>Moderateur</dt>
                <dd>
                  {site?.moderator_first_name || site?.moderator_last_name
                    ? `${site?.moderator_first_name || ''} ${site?.moderator_last_name || ''}`.trim()
                    : 'Aucun'}
                </dd>
              </div>
            </dl>
          </article>

          <article className="panel">
            <SectionHeader
              eyebrow="Moderation"
              title="Decision admin"
              copy="Cette decision sera visible cote professionnel avec la note associee."
            />
            <ModerationForm
              action={action}
              actions={siteModerationActions}
              feedback={feedback}
              isSubmitting={isSubmitting}
              notes={notes}
              onActionChange={setAction}
              onNotesChange={setNotes}
              onSubmit={handleModeration}
              submitLabel="Enregistrer la decision"
            />
          </article>
        </div>
      )}
    </section>
  );
}

function ReviewsPage() {
  const {
    isLoading,
    loadDashboard,
    pendingReviews,
    reviewPagination,
    setReviewPagination
  } = useAdminContext();

  return (
    <section className="panel">
      <SectionHeader
        eyebrow="Moderation avis"
        title="Avis en attente"
        count={pendingReviews.length}
        copy="Publication, rejet ou masquage des avis soumis par la communaute."
      />
      <PendingReviewsList
        items={pendingReviews}
        isLoading={isLoading}
        onModerated={loadDashboard}
      />
      <PaginationControls
        pagination={reviewPagination}
        onPageChange={(page) =>
          setReviewPagination((current) => ({ ...current, page }))
        }
        onLimitChange={(limit) =>
          setReviewPagination((current) => ({ ...current, page: 1, limit }))
        }
      />
    </section>
  );
}

function ReviewDetailPage() {
  const { reviewId } = useParams();
  const { loadDashboard } = useAdminContext();
  const navigate = useNavigate();
  const [review, setReview] = useState(null);
  const [isLoadingDetail, setIsLoadingDetail] = useState(true);
  const [error, setError] = useState('');
  const [action, setAction] = useState('APPROVE');
  const [notes, setNotes] = useState('');
  const [feedback, setFeedback] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const loadDetail = async () => {
    setIsLoadingDetail(true);
    setError('');
    try {
      const detail = await fetchAdminReviewDetail(reviewId);
      setReview(detail);
      setNotes(detail.moderation_notes || '');
    } catch (err) {
      setError(err.message || 'Impossible de charger la fiche avis.');
    } finally {
      setIsLoadingDetail(false);
    }
  };

  useEffect(() => {
    loadDetail();
  }, [reviewId]);

  const handleModeration = async () => {
    setIsSubmitting(true);
    setFeedback('');
    try {
      await moderateReview(reviewId, action, notes);
      setFeedback('Decision de moderation enregistree.');
      await Promise.all([loadDetail(), loadDashboard()]);
    } catch (err) {
      setFeedback(err.message || 'Moderation impossible.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <section className="detail-page">
      <div className="detail-toolbar">
        <button
          type="button"
          className="ghost-button compact"
          onClick={() => navigate('/dashboard/reviews')}
        >
          Retour aux avis
        </button>
      </div>
      {isLoadingDetail ? (
        <div className="panel empty-state">Chargement de la fiche avis...</div>
      ) : error ? (
        <div className="panel alert error">{error}</div>
      ) : (
        <div className="detail-grid">
          <article className="panel">
            <SectionHeader
              eyebrow="Detail avis"
              title={review?.title || 'Avis sans titre'}
              badge={review?.moderation_status || 'PENDING'}
              copy={`${review?.site_name || 'Lieu inconnu'}${review?.site_city ? ` · ${review.site_city}` : ''}`}
            />
            <dl className="kpi-list">
              <div>
                <dt>Note globale</dt>
                <dd>{formatRating(review?.overall_rating)}</dd>
              </div>
              <div>
                <dt>Statut</dt>
                <dd>{review?.status || 'Inconnu'}</dd>
              </div>
              <div>
                <dt>Visite</dt>
                <dd>{review?.visit_type || 'Non renseignee'}</dd>
              </div>
              <div>
                <dt>Date de visite</dt>
                <dd>{formatDate(review?.visit_date)}</dd>
              </div>
              <div>
                <dt>Helpful</dt>
                <dd>{review?.helpful_count ?? 0}</dd>
              </div>
              <div>
                <dt>Reports</dt>
                <dd>{review?.reports_count ?? 0}</dd>
              </div>
            </dl>
            <div className="detail-block">
              <p className="eyebrow muted">Contenu</p>
              <p>{review?.content || 'Aucun contenu.'}</p>
            </div>
          </article>

          <article className="panel">
            <SectionHeader
              eyebrow="Auteur"
              title="Contexte moderation"
              copy="Conserve la trace de l auteur, du lieu et des dernieres decisions."
            />
            <dl className="kpi-list">
              <div>
                <dt>Auteur</dt>
                <dd>
                  {review?.author_first_name || ''} {review?.author_last_name || ''}
                </dd>
              </div>
              <div>
                <dt>Email auteur</dt>
                <dd>{review?.author_email || 'Non renseigne'}</dd>
              </div>
              <div>
                <dt>Lieu</dt>
                <dd>{review?.site_name || 'Inconnu'}</dd>
              </div>
              <div>
                <dt>Region</dt>
                <dd>
                  {review?.site_city || ''}{review?.site_region ? `, ${review.site_region}` : ''}
                </dd>
              </div>
              <div>
                <dt>Cree le</dt>
                <dd>{formatDateTime(review?.created_at)}</dd>
              </div>
              <div>
                <dt>Mis a jour le</dt>
                <dd>{formatDateTime(review?.updated_at)}</dd>
              </div>
              <div>
                <dt>Derniere moderation</dt>
                <dd>{formatDateTime(review?.moderated_at)}</dd>
              </div>
              <div>
                <dt>Moderateur</dt>
                <dd>
                  {review?.moderator_first_name || review?.moderator_last_name
                    ? `${review?.moderator_first_name || ''} ${review?.moderator_last_name || ''}`.trim()
                    : 'Aucun'}
                </dd>
              </div>
            </dl>
          </article>

          <article className="panel">
            <SectionHeader
              eyebrow="Moderation"
              title="Decision admin"
              copy="Publication, rejet ou masquage de l avis avec note explicative."
            />
            <ModerationForm
              action={action}
              actions={reviewModerationActions}
              feedback={feedback}
              isSubmitting={isSubmitting}
              notes={notes}
              onActionChange={setAction}
              onNotesChange={setNotes}
              onSubmit={handleModeration}
              submitLabel="Moderer l avis"
            />
          </article>
        </div>
      )}
    </section>
  );
}

function UsersPage() {
  const { userId } = useParams();
  const {
    isAdmin,
    isLoading,
    loadDashboard,
    setUserFilters,
    setUserPagination,
    userFilters,
    userPagination,
    users
  } = useAdminContext();
  const navigate = useNavigate();
  const selectedUser = users.find((item) => String(item.id) === userId) || null;

  return (
    <section className="panel users-panel">
      <SectionHeader
        eyebrow="Gestion utilisateurs"
        title="Comptes et statuts"
        badge={isAdmin ? 'ADMIN' : 'Lecture seule'}
        copy="Les modificateurs de statut sont disponibles uniquement pour ADMIN. Les comptes MODERATOR gardent une vue de consultation."
      />
      <UsersSection
        canManage={isAdmin}
        filters={userFilters}
        isLoading={isLoading}
        items={users}
        onFiltersChange={(updater) => {
          setUserPagination((current) => ({ ...current, page: 1 }));
          setUserFilters(updater);
        }}
        onSelectUser={(id) => navigate(`/dashboard/users/${id}`)}
        onUpdated={loadDashboard}
        selectedUserId={selectedUser?.id || null}
      />
      <PaginationControls
        pagination={userPagination}
        onPageChange={(page) =>
          setUserPagination((current) => ({ ...current, page }))
        }
        onLimitChange={(limit) =>
          setUserPagination((current) => ({ ...current, page: 1, limit }))
        }
      />
      <UserDetailPanel
        onClearSelection={() => navigate('/dashboard/users')}
        user={selectedUser}
      />
    </section>
  );
}

function SectionHeader({ badge, copy, count, eyebrow, title }) {
  return (
    <>
      <div className="panel-head">
        <div>
          <p className="eyebrow muted">{eyebrow}</p>
          <h2>{title}</h2>
        </div>
        {typeof count === 'number' && <span className="panel-count">{count}</span>}
        {badge ? <span className="role-pill admin-only">{badge}</span> : null}
      </div>
      {copy ? <p className="panel-copy">{copy}</p> : null}
    </>
  );
}

function SummaryActionCard({ helper, label, onOpen, value }) {
  return (
    <article className="summary-card">
      <p>{label}</p>
      <strong>{value}</strong>
      <span>{helper}</span>
      <button type="button" className="ghost-button compact" onClick={onOpen}>
        Ouvrir
      </button>
    </article>
  );
}

function PaginationControls({ onLimitChange, onPageChange, pagination }) {
  const page = Number(pagination?.page || 1);
  const limit = Number(pagination?.limit || 1);
  const total = Number(pagination?.total || 0);
  const totalPages = Math.max(1, Math.ceil(total / Math.max(limit, 1)));

  return (
    <div className="pagination-bar">
      <div className="pagination-copy">
        <strong>
          Page {page} / {totalPages}
        </strong>
        <span>{total} elements au total</span>
      </div>
      <div className="pagination-actions">
        <label className="page-size-control">
          <span>Par page</span>
          <select
            value={limit}
            onChange={(event) => onLimitChange(Number(event.target.value))}
          >
            {[5, 10, 20, 50].map((option) => (
              <option key={option} value={option}>
                {option}
              </option>
            ))}
          </select>
        </label>
        <button
          type="button"
          className="ghost-button compact"
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
        >
          Precedent
        </button>
        <button
          type="button"
          className="ghost-button compact"
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages}
        >
          Suivant
        </button>
      </div>
    </div>
  );
}

function PendingSitesList({ items, isLoading, onModerated }) {
  if (isLoading) {
    return <div className="empty-state">Chargement des sites en attente...</div>;
  }

  if (!items.length) {
    return (
      <div className="empty-state">
        Aucun site en attente pour le moment. Le backlog moderation est vide.
      </div>
    );
  }

  return (
    <div className="card-list">
      {items.map((site) => (
        <PendingSiteCard key={site.id} site={site} onModerated={onModerated} />
      ))}
    </div>
  );
}

function PendingSiteCard({ site, onModerated }) {
  const navigate = useNavigate();
  const [action, setAction] = useState('APPROVE');
  const [notes, setNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [feedback, setFeedback] = useState('');
  const ownerName = [site.owner_first_name, site.owner_last_name]
    .filter(Boolean)
    .join(' ')
    .trim();

  const handleModeration = async () => {
    setIsSubmitting(true);
    setFeedback('');

    try {
      const result = await moderateSite(site.id, action, notes);
      setFeedback(
        action === 'APPROVE'
          ? 'Site approuve et publie.'
          : `Decision enregistree: ${result.verification_status}.`
      );
      setNotes('');
      await onModerated();
    } catch (err) {
      setFeedback(err.message || 'Moderation impossible.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <article className="admin-card">
      <div className="card-head">
        <div>
          <h3>{site.name}</h3>
          <p className="site-meta">
            {site.city}, {site.region}
          </p>
        </div>
        <span className="status-pill pending">PENDING</span>
      </div>
      <dl className="entity-details">
        <div>
          <dt>Proprietaire</dt>
          <dd>{ownerName || 'Non renseigne'}</dd>
        </div>
        <div>
          <dt>Soumis le</dt>
          <dd>{formatDate(site.created_at)}</dd>
        </div>
      </dl>
      <div className="card-actions">
        <button
          type="button"
          className="ghost-button compact"
          onClick={() => navigate(`/dashboard/sites/${site.id}`)}
        >
          Ouvrir la fiche
        </button>
      </div>
      <ModerationForm
        action={action}
        actions={siteModerationActions}
        feedback={feedback}
        isSubmitting={isSubmitting}
        notes={notes}
        onActionChange={setAction}
        onNotesChange={setNotes}
        onSubmit={handleModeration}
        submitLabel="Enregistrer la decision"
      />
    </article>
  );
}

function PendingReviewsList({ items, isLoading, onModerated }) {
  if (isLoading) {
    return <div className="empty-state">Chargement des avis en attente...</div>;
  }

  if (!items.length) {
    return (
      <div className="empty-state">
        Aucun avis en attente. La file de moderation est propre.
      </div>
    );
  }

  return (
    <div className="card-list">
      {items.map((review) => (
        <PendingReviewCard
          key={review.id}
          review={review}
          onModerated={onModerated}
        />
      ))}
    </div>
  );
}

function PendingReviewCard({ review, onModerated }) {
  const navigate = useNavigate();
  const [action, setAction] = useState('APPROVE');
  const [notes, setNotes] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [feedback, setFeedback] = useState('');
  const authorName = [review.first_name, review.last_name]
    .filter(Boolean)
    .join(' ')
    .trim();

  const handleModeration = async () => {
    setIsSubmitting(true);
    setFeedback('');

    try {
      const result = await moderateReview(review.id, action, notes);
      setFeedback(`Decision enregistree: ${result.moderation_status}.`);
      setNotes('');
      await onModerated();
    } catch (err) {
      setFeedback(err.message || 'Moderation de l avis impossible.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <article className="admin-card">
      <div className="card-head">
        <div>
          <h3>{review.title || 'Avis sans titre'}</h3>
          <p className="site-meta">{review.site_name}</p>
        </div>
        <span className="rating-pill">{formatRating(review.overall_rating)}</span>
      </div>
      <dl className="entity-details">
        <div>
          <dt>Auteur</dt>
          <dd>{authorName || 'Utilisateur inconnu'}</dd>
        </div>
        <div>
          <dt>Soumis le</dt>
          <dd>{formatDate(review.created_at)}</dd>
        </div>
      </dl>
      <div className="card-actions">
        <button
          type="button"
          className="ghost-button compact"
          onClick={() => navigate(`/dashboard/reviews/${review.id}`)}
        >
          Ouvrir la fiche
        </button>
      </div>
      <ModerationForm
        action={action}
        actions={reviewModerationActions}
        feedback={feedback}
        isSubmitting={isSubmitting}
        notes={notes}
        onActionChange={setAction}
        onNotesChange={setNotes}
        onSubmit={handleModeration}
        submitLabel="Moderer l avis"
      />
    </article>
  );
}

function ModerationForm({
  action,
  actions,
  feedback,
  isSubmitting,
  notes,
  onActionChange,
  onNotesChange,
  onSubmit,
  submitLabel
}) {
  return (
    <div className="moderation-box">
      <label className="field">
        <span>Decision</span>
        <select
          value={action}
          onChange={(event) => onActionChange(event.target.value)}
        >
          {actions.map((item) => (
            <option key={item.value} value={item.value}>
              {item.label}
            </option>
          ))}
        </select>
      </label>
      <label className="field">
        <span>Note de moderation</span>
        <textarea
          rows="3"
          placeholder="Expliquer clairement la decision..."
          value={notes}
          onChange={(event) => onNotesChange(event.target.value)}
        />
      </label>
      {feedback && (
        <div
          className={feedback.includes('impossible') ? 'alert error' : 'alert success'}
        >
          {feedback}
        </div>
      )}
      <button
        type="button"
        className="primary-button"
        onClick={onSubmit}
        disabled={isSubmitting}
      >
        {isSubmitting ? 'Enregistrement...' : submitLabel}
      </button>
    </div>
  );
}

function UsersSection({
  canManage,
  filters,
  isLoading,
  items,
  onFiltersChange,
  onSelectUser,
  onUpdated,
  selectedUserId
}) {
  const [searchDraft, setSearchDraft] = useState(filters.q);

  useEffect(() => {
    setSearchDraft(filters.q);
  }, [filters.q]);

  const submitFilters = (event) => {
    event.preventDefault();
    onFiltersChange((current) => ({ ...current, q: searchDraft.trim() }));
  };

  return (
    <div className="users-section">
      <form className="filters-grid" onSubmit={submitFilters}>
        <label className="field">
          <span>Recherche</span>
          <input
            type="search"
            value={searchDraft}
            placeholder="Email, prenom, nom..."
            onChange={(event) => setSearchDraft(event.target.value)}
          />
        </label>
        <label className="field">
          <span>Role</span>
          <select
            value={filters.role}
            onChange={(event) =>
              onFiltersChange((current) => ({
                ...current,
                role: event.target.value
              }))
            }
          >
            {userRoleOptions.map((option) => (
              <option key={option.value || 'all'} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
        <label className="field">
          <span>Statut</span>
          <select
            value={filters.status}
            onChange={(event) =>
              onFiltersChange((current) => ({
                ...current,
                status: event.target.value
              }))
            }
          >
            {userStatusFilters.map((option) => (
              <option key={option.value || 'all'} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
        <div className="filters-actions">
          <button type="submit" className="primary-button">
            Appliquer
          </button>
          <button
            type="button"
            className="ghost-button"
            onClick={() => onFiltersChange({ q: '', role: '', status: '' })}
          >
            Reinitialiser
          </button>
        </div>
      </form>

      {isLoading ? (
        <div className="empty-state">Chargement des utilisateurs...</div>
      ) : !items.length ? (
        <div className="empty-state">
          Aucun utilisateur ne correspond aux filtres actuels.
        </div>
      ) : (
        <div className="table-wrap">
          <table className="users-table">
            <thead>
              <tr>
                <th>Utilisateur</th>
                <th>Role</th>
                <th>Statut</th>
                <th>Progression</th>
                <th>Derniere connexion</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <UserRow
                  key={item.id}
                  canManage={canManage}
                  isSelected={selectedUserId === item.id}
                  item={item}
                  onSelect={onSelectUser}
                  onUpdated={onUpdated}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

function UserRow({ canManage, isSelected, item, onSelect, onUpdated }) {
  const [status, setStatus] = useState(item.status || 'ACTIVE');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [feedback, setFeedback] = useState('');

  const displayName = [item.first_name, item.last_name].filter(Boolean).join(' ');

  useEffect(() => {
    setStatus(item.status || 'ACTIVE');
  }, [item.status]);

  const handleStatusUpdate = async () => {
    setIsSubmitting(true);
    setFeedback('');

    try {
      const updated = await updateUserStatus(item.id, status);
      setStatus(updated.status || status);
      setFeedback('Statut mis a jour.');
      await onUpdated();
    } catch (err) {
      setFeedback(err.message || 'Mise a jour impossible.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <tr
      className={isSelected ? 'table-row-selected' : ''}
      onClick={() => onSelect(item.id)}
    >
      <td>
        <div className="user-identity">
          <strong>{displayName || 'Utilisateur sans nom'}</strong>
          <span>{item.email}</span>
        </div>
      </td>
      <td>{item.role}</td>
      <td>
        <span className={`status-pill ${statusToClass(item.status)}`}>
          {item.status}
        </span>
      </td>
      <td>
        <div className="user-progress">
          <strong>{item.points ?? 0} pts</strong>
          <span>
            Niveau {item.level ?? 1} | {item.rank || 'BRONZE'}
          </span>
        </div>
      </td>
      <td>{formatDateTime(item.last_login_at)}</td>
      <td onClick={(event) => event.stopPropagation()}>
        {canManage ? (
          <div className="user-actions">
            <select
              value={status}
              onChange={(event) => setStatus(event.target.value)}
            >
              {userStatusOptions.map((option) => (
                <option key={option.value} value={option.value}>
                  {option.label}
                </option>
              ))}
            </select>
            <button
              type="button"
              className="ghost-button compact"
              onClick={handleStatusUpdate}
              disabled={isSubmitting || status === item.status}
            >
              {isSubmitting ? 'Mise a jour...' : 'Mettre a jour'}
            </button>
          </div>
        ) : (
          <span className="muted-inline">ADMIN requis</span>
        )}
        {feedback && (
          <div
            className={
              feedback.includes('impossible')
                ? 'table-feedback error'
                : 'table-feedback success'
            }
          >
            {feedback}
          </div>
        )}
      </td>
    </tr>
  );
}

function UserDetailPanel({ onClearSelection, user }) {
  return (
    <aside className="detail-panel">
      <SectionHeader
        eyebrow="Detail utilisateur"
        title={user ? 'Fiche selectionnee' : 'Aucun utilisateur selectionne'}
        copy={
          user
            ? 'Lecture rapide du compte actif pour garder le contexte pendant la moderation.'
            : 'Choisis un compte dans le tableau pour voir ses informations ici.'
        }
      />
      {user ? (
        <button
          type="button"
          className="ghost-button compact detail-clear-button"
          onClick={onClearSelection}
        >
          Fermer la fiche
        </button>
      ) : null}
      <UserDetailCompact user={user} expanded />
    </aside>
  );
}

function UserDetailCompact({ expanded = false, user }) {
  if (!user) {
    return (
      <div className="empty-state">
        Aucun compte selectionne pour le moment.
      </div>
    );
  }

  const displayName = [user.first_name, user.last_name].filter(Boolean).join(' ');

  return (
    <div className={`user-detail-card ${expanded ? 'expanded' : ''}`}>
      <div className="user-detail-head">
        <div>
          <h3>{displayName || 'Utilisateur sans nom'}</h3>
          <p className="site-meta">{user.email}</p>
        </div>
        <span className={`status-pill ${statusToClass(user.status)}`}>
          {user.status}
        </span>
      </div>
      <dl className="kpi-list compact">
        <div>
          <dt>Role</dt>
          <dd>{user.role}</dd>
        </div>
        <div>
          <dt>Points</dt>
          <dd>{user.points ?? 0}</dd>
        </div>
        <div>
          <dt>Niveau</dt>
          <dd>{user.level ?? 1}</dd>
        </div>
        <div>
          <dt>Rang</dt>
          <dd>{user.rank || 'BRONZE'}</dd>
        </div>
        <div>
          <dt>Inscrit le</dt>
          <dd>{formatDate(user.created_at)}</dd>
        </div>
        <div>
          <dt>Derniere connexion</dt>
          <dd>{formatDateTime(user.last_login_at)}</dd>
        </div>
      </dl>
    </div>
  );
}

function StatCard({ isLoading, label, tone, value }) {
  return (
    <article className={`stat-card ${tone}`}>
      <p>{label}</p>
      <strong>{isLoading ? '...' : value ?? 0}</strong>
    </article>
  );
}

function useAdminContext() {
  return useOutletContext();
}

function tabClassName(isActive) {
  return `tab-button ${isActive ? 'active' : ''}`;
}

function statusToClass(status) {
  switch (status) {
    case 'ACTIVE':
      return 'verified';
    case 'SUSPENDED':
      return 'danger';
    case 'INACTIVE':
      return 'muted';
    default:
      return 'pending';
  }
}

function formatRating(value) {
  const rating = Number(value || 0);
  return `${rating.toFixed(1)} / 5`;
}

function formatDate(value) {
  if (!value) return 'Date inconnue';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return String(value);

  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric'
  }).format(date);
}

function formatDateTime(value) {
  if (!value) return 'Jamais';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return String(value);

  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date);
}

export default App;
